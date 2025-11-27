//! Parse protobuf binary encoding without copying data

// Proto schema:
// message PhoneNumber { optional string number = 1; optional string type = 2; }
// message Person { optional string name = 1; optional int32 id = 2; repeated PhoneNumber phones = 3; }

enum WireType {
    Varint,
    Len,
}

#[derive(Debug)]
enum FieldValue<'a> {
    Varint(u64),
    Len(&'a [u8]),
}

#[derive(Debug)]
struct Field<'a> {
    field_num: u64,
    value: FieldValue<'a>,
}

trait ProtoMessage<'a>: Default {
    fn add_field(&mut self, field: Field<'a>);
}

impl From<u64> for WireType {
    fn from(value: u64) -> Self {
        match value {
            0 => WireType::Varint,
            2 => WireType::Len,
            _ => panic!("Invalid wire type: {value}"),
        }
    }
}

impl<'a> FieldValue<'a> {
    fn as_str(&self) -> &'a str {
        let FieldValue::Len(data) = self else {
            panic!("expected Len");
        };
        std::str::from_utf8(data).expect("invalid utf8")
    }

    fn as_bytes(&self) -> &'a [u8] {
        let FieldValue::Len(data) = self else {
            panic!("expected Len");
        };
        data
    }

    fn as_u64(&self) -> u64 {
        let FieldValue::Varint(value) = self else {
            panic!("expected Varint");
        };
        *value
    }
}

fn parse_varint(data: &[u8]) -> (u64, &[u8]) {
    for i in 0..7 {
        let Some(b) = data.get(i) else {
            panic!("not enough bytes");
        };
        if b & 0x80 == 0 {
            let mut value = 0u64;
            for b in data[..=i].iter().rev() {
                value = (value << 7) | (b & 0x7f) as u64;
            }
            return (value, &data[i + 1..]);
        }
    }
    panic!("varint too long");
}

fn unpack_tag(tag: u64) -> (u64, WireType) {
    let field_num = tag >> 3;
    let wire_type = WireType::from(tag & 0x7);
    (field_num, wire_type)
}

fn parse_field(data: &[u8]) -> (Field<'_>, &[u8]) {
    let (tag, remainder) = parse_varint(data);
    let (field_num, wire_type) = unpack_tag(tag);
    // TODO: Match on wire_type to build FieldValue and consume bytes
    // - Varint: call parse_varint(remainder) to get (value, remainder)
    // - Len: call parse_varint(remainder) to get length, then use split_at(len) on remainder
    // Hint: cast len to usize with `as usize`
    let (fieldvalue, remainder) = match wire_type {
        WireType::Varint => todo!("call parse_varint, wrap in FieldValue::Varint"),
        WireType::Len => todo!("parse length, split_at, wrap in FieldValue::Len"),
    };
    // TODO: Return (Field { field_num, value: fieldvalue }, remainder)
    todo!("build Field struct")
}

fn parse_message<'a, T: ProtoMessage<'a>>(mut data: &'a [u8]) -> T {
    let mut result = T::default();
    while !data.is_empty() {
        let parsed = parse_field(data);
        result.add_field(parsed.0);
        data = parsed.1;
    }
    result
}

#[derive(Debug, Default, PartialEq)]
struct PhoneNumber<'a> {
    number: &'a str,
    type_: &'a str,
}

#[derive(Debug, Default, PartialEq)]
struct Person<'a> {
    name: &'a str,
    id: u64,
    phone: Vec<PhoneNumber<'a>>,
}

// TODO: Implement ProtoMessage for PhoneNumber
// Hint: match field.field_num, use _ => {} to ignore unknown fields
// - field 1 (number): self.number = field.value.as_str()
// - field 2 (type_): self.type_ = field.value.as_str()

// TODO: Implement ProtoMessage for Person
// Hint: match field.field_num, use _ => {} to ignore unknown fields
// - field 1 (name): self.name = field.value.as_str()
// - field 2 (id): self.id = field.value.as_u64()
// - field 3 (phone): self.phone.push(parse_message(field.value.as_bytes()))

#[test]
fn test_id() {
    let person_id: Person = parse_message(&[0x10, 0x2a]);
    assert_eq!(
        person_id,
        Person {
            name: "",
            id: 42,
            phone: vec![]
        }
    );
}

#[test]
fn test_name() {
    let person_name: Person = parse_message(&[
        0x0a, 0x0e, 0x62, 0x65, 0x61, 0x75, 0x74, 0x69, 0x66, 0x75, 0x6c, 0x20, 0x6e, 0x61, 0x6d,
        0x65,
    ]);
    assert_eq!(
        person_name,
        Person {
            name: "beautiful name",
            id: 0,
            phone: vec![]
        }
    );
}

#[test]
fn test_just_person() {
    let person_name_id: Person = parse_message(&[0x0a, 0x04, 0x45, 0x76, 0x61, 0x6e, 0x10, 0x16]);
    assert_eq!(
        person_name_id,
        Person {
            name: "Evan",
            id: 22,
            phone: vec![]
        }
    );
}

#[test]
fn test_phone() {
    let phone: Person = parse_message(&[
        0x0a, 0x00, 0x10, 0x00, 0x1a, 0x16, 0x0a, 0x0e, 0x2b, 0x31, 0x32, 0x33, 0x34, 0x2d, 0x37,
        0x37, 0x37, 0x2d, 0x39, 0x30, 0x39, 0x30, 0x12, 0x04, 0x68, 0x6f, 0x6d, 0x65,
    ]);
    assert_eq!(
        phone,
        Person {
            name: "",
            id: 0,
            phone: vec![PhoneNumber {
                number: "+1234-777-9090",
                type_: "home"
            },],
        }
    );
}

#[test]
fn test_full_person() {
    let person: Person = parse_message(&[
        0x0a, 0x07, 0x6d, 0x61, 0x78, 0x77, 0x65, 0x6c, 0x6c, 0x10, 0x2a, 0x1a, 0x16, 0x0a, 0x0e,
        0x2b, 0x31, 0x32, 0x30, 0x32, 0x2d, 0x35, 0x35, 0x35, 0x2d, 0x31, 0x32, 0x31, 0x32, 0x12,
        0x04, 0x68, 0x6f, 0x6d, 0x65, 0x1a, 0x18, 0x0a, 0x0e, 0x2b, 0x31, 0x38, 0x30, 0x30, 0x2d,
        0x38, 0x36, 0x37, 0x2d, 0x35, 0x33, 0x30, 0x38, 0x12, 0x06, 0x6d, 0x6f, 0x62, 0x69, 0x6c,
        0x65,
    ]);
    assert_eq!(
        person,
        Person {
            name: "maxwell",
            id: 42,
            phone: vec![
                PhoneNumber {
                    number: "+1202-555-1212",
                    type_: "home"
                },
                PhoneNumber {
                    number: "+1800-867-5308",
                    type_: "mobile"
                },
            ]
        }
    );
}
