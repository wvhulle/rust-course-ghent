//! Builder Pattern Exercise
//!
//! Implement a builder pattern for constructing Package structs

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
        todo!("Return a Dependency with this package's name and version")
    }
}

struct PackageBuilder(Package);

impl PackageBuilder {
    fn new(_name: impl Into<String>) -> Self {
        todo!("Create a PackageBuilder with the given name, empty version, empty authors, empty dependencies, and None for language")
    }

    fn version(mut self, version: impl Into<String>) -> Self {
        self.0.version = version.into();
        self
    }

    fn authors(mut self, _authors: Vec<String>) -> Self {
        todo!("Set the authors field and return self")
    }

    fn dependency(mut self, _dependency: Dependency) -> Self {
        todo!("Add the dependency to the dependencies Vec and return self")
    }

    fn language(mut self, _language: Language) -> Self {
        todo!("Set the language to Some(language) and return self")
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

