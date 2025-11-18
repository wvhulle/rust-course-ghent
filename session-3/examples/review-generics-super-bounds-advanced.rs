//! Multiple bounds on supertrait associated types

trait Collection {
    type Element;

    fn elements(&self) -> Vec<Self::Element>;
}

trait SortableCollection: Collection
where
    Self::Element: Ord + Clone,
{
    fn sorted(&self) -> Vec<Self::Element> {
        todo!("Step 1: Get elements using self.elements()");
        todo!("Step 2: Sort using sort() and return them");
    }
}

struct NumberList {
    numbers: Vec<i32>,
}

impl Collection for NumberList {
    type Element = i32;

    fn elements(&self) -> Vec<Self::Element> {
        self.numbers.clone()
    }
}

impl SortableCollection for NumberList {}

fn demonstrate_sorting() {
    let list = NumberList {
        numbers: vec![3, 1, 4, 1, 5, 9],
    };
    dbg!(list.sorted());
}

// Attempt 1: Can we make a collection of non-sortable items sortable?
//
// struct NotOrd {
//     value: i32,
// }
//
// struct CustomList {
//     items: Vec<NotOrd>,
// }
//
// impl Collection for CustomList {
//     type Element = NotOrd;
//
//     fn elements(&self) -> Vec<Self::Element> {
//         self.items.clone()
//     }
// }
//
// impl SortableCollection for CustomList {}

trait Repository {
    type Record;

    fn find_all(&self) -> Vec<Self::Record>;
}

trait DebuggableRepository: Repository
where
    Self::Record: std::fmt::Debug,
{
    fn debug_all(&self) {
        todo!("Step 3: Get all records using find_all() and print with dbg!");
    }
}

struct UserRepository {
    users: Vec<String>,
}

impl Repository for UserRepository {
    type Record = String;

    fn find_all(&self) -> Vec<Self::Record> {
        self.users.clone()
    }
}

impl DebuggableRepository for UserRepository {}

// Attempt 2: Can we debug non-Debug types?
//
// struct NoDebug {
//     secret: String,
// }
//
// struct SecretRepository {
//     secrets: Vec<NoDebug>,
// }
//
// impl Repository for SecretRepository {
//     type Record = NoDebug;
//
//     fn find_all(&self) -> Vec<Self::Record> {
//         self.secrets.clone()
//     }
// }
//
// impl DebuggableRepository for SecretRepository {}

trait DataSource {
    type Item;

    fn fetch(&self) -> Vec<Self::Item>;
}

trait SerializableDataSource: DataSource
where
    Self::Item: std::fmt::Display + Clone,
{
    fn to_strings(&self) -> Vec<String> {
        todo!("Step 4: Fetch items and convert each to String using to_string()");
    }
}

struct NumberSource {
    numbers: Vec<i32>,
}

impl DataSource for NumberSource {
    type Item = i32;

    fn fetch(&self) -> Vec<Self::Item> {
        self.numbers.clone()
    }
}

impl SerializableDataSource for NumberSource {}

fn main() {
    demonstrate_sorting();

    todo!("Uncomment Attempt 1 - Can non-Ord types be sorted?");
    todo!("Uncomment Attempt 2 - Can non-Debug types be debugged?");

    let repo = UserRepository {
        users: vec!["Alice".to_string(), "Bob".to_string()],
    };
    repo.debug_all();

    let source = NumberSource {
        numbers: vec![1, 2, 3],
    };
    dbg!(source.to_strings());
}
