use std::env;
use std::fs;
use std::io::{self, Write};
use std::process::Command;

fn main() -> io::Result<()> {
    let env_home = env::var("ENV_HOME").unwrap_or_else(|_| {
        let home = env::var("HOME").unwrap_or_else(|_| ".".to_string());
        format!("{}/.virtualenvs", home)
    });
    let workon_home = format!("{}/envs", env_home);

    let mut args = env::args().skip(1);
    let cmd = match args.next() {
        Some(c) => c,
        None => {
            eprintln!("Usage: rustenv <command> [args]");
            std::process::exit(1);
        }
    };

    match cmd.as_str() {
        "mkenv" => {
            let version = args.next().expect("missing python version");
            let env_name = args.next().expect("missing env name");
            mkenv(&workon_home, &version, &env_name)?;
        }
        "rmenv" => {
            let env_name = args.next().expect("missing env name");
            let force = args.next() == Some("-y".to_string());
            rmenv(&workon_home, &env_name, force)?;
        }
        "lsenv" => {
            lsenv(&workon_home)?;
        }
        _ => {
            eprintln!("Unknown command");
            std::process::exit(1);
        }
    }

    Ok(())
}

fn mkenv(workon_home: &str, version: &str, env_name: &str) -> io::Result<()> {
    let output = Command::new("mise")
        .args(["where", &format!("python@{}", version)])
        .output()?;

    if !output.status.success() {
        eprintln!("Failed to locate Python version {}", version);
        std::process::exit(1);
    }

    let python_path = String::from_utf8_lossy(&output.stdout).trim().to_string();

    let status = Command::new("virtualenv")
        .arg("-p")
        .arg(format!("{}/bin/python", python_path))
        .arg(format!("{}/{}", workon_home, env_name))
        .status()?;

    if !status.success() {
        eprintln!("virtualenv failed");
        std::process::exit(1);
    }

    Ok(())
}

fn rmenv(workon_home: &str, env_name: &str, force: bool) -> io::Result<()> {
    if !force {
        print!(
            "Removing virtualenv {}. This action cannot be undone. Are you sure? (y/n) ",
            env_name
        );
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        if !input.trim().eq_ignore_ascii_case("y") {
            println!("Virtualenv removal canceled.");
            return Ok(());
        }
    }

    let path = format!("{}/{}", workon_home, env_name);
    fs::remove_dir_all(&path)?;
    println!("Virtualenv {} successfully removed.", env_name);
    Ok(())
}

fn lsenv(workon_home: &str) -> io::Result<()> {
    for entry in fs::read_dir(workon_home)? {
        let entry = entry?;
        if entry.file_type()?.is_dir() {
            println!("{}", entry.file_name().to_string_lossy());
        }
    }
    Ok(())
}
