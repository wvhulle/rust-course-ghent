//! Builder Pattern Exercise

#[derive(Debug)]
enum Language {
    Rust,
    Java,
    Perl,
}

#[derive(Clone, Debug)]
struct Dependency {
    name: String,
    version_expression: String,
}

#[derive(Debug)]
struct Package {
    name: String,
    version: String,
    authors: Vec<String>,
    dependencies: Vec<Dependency>,
    language: Option<Language>,
}

impl Package {
    fn as_dependency(&self) -> Dependency {
        // TODO: Return a Dependency with this package's name and version
        todo!("return value")
    }
}

struct PackageBuilder(Package);

impl PackageBuilder {
    fn new(_name: impl Into<String>) -> Self {
        // TODO: Create a PackageBuilder wrapping a Package
        // TODO: Set name from parameter, empty version, empty vecs, None language
        todo!("convert type")
    }

    fn version(mut self, version: impl Into<String>) -> Self {
        self.0.version = version.into();
        self
    }

    fn authors(mut self, _authors: Vec<String>) -> Self {
        // TODO: Set the authors field and return self
        todo!("return self")
    }

    fn dependency(mut self, _dependency: Dependency) -> Self {
        // TODO: Push the dependency to dependencies Vec and return self
        todo!("push item")
    }

    fn language(mut self, _language: Language) -> Self {
        // TODO: Set language to Some(_language) and return self
        todo!("handle Option")
    }

    fn build(self) -> Package {
        self.0
    }
}

fn main() {
    let base64 = PackageBuilder::new("base64").version("0.13").build();
    dbg!(&base64);
    let log = PackageBuilder::new("log")
        .version("0.4")
        .language(Language::Rust)
        .build();
    dbg!(&log);
    let serde = PackageBuilder::new("serde")
        .authors(vec!["djmitche".into()])
        .version(String::from("4.0"))
        .dependency(base64.as_dependency())
        .dependency(log.as_dependency())
        .build();
    dbg!(serde);
}
