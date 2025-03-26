# Virtualenv Setup

This repository contains a personal virtualenv setup using **mise** and **virtualenv** to replace Anaconda for managing Python environments. It's designed to be simple, efficient, and flexible.

## Prerequisites

Ensure you have **mise** installed before using this virtualenv setup.

### Install mise

- **Linux**:
  ```bash
  curl https://mise.run | sh
  ```

- **macOS** (with Homebrew):
  ```bash
  brew install mise
  ```

### Install Python (latest version)
After installing mise, set up Python globally by running:

```bash
mise use --global python@3
```

### Install virtualenv
Next, ensure `virtualenv` is installed by running:

```bash
pip install virtualenv
```

## Installation

Follow these steps to install and configure the virtualenv setup on your system:

1. **Clone the Repository**
   First, clone this repository into the `.virtualenvs` directory in your home folder by using the following command:
   ```bash
   git clone https://github.com/taintlesscupcake/virtualenv ~/.virtualenvs
   ```

2. **Configure Shell**
   Add the following lines to your shell configuration file (`.zshrc` or `.bashrc`):
   ```bash
   export ENV_HOME="$HOME/.virtualenvs"
   source $ENV_HOME/virtualenv.sh
   ```

## Usage

With the setup complete, you can use the following commands to manage your Python environments:

- **Create a new environment**: `mkenv <python_version> <env_name>`
- **Activate an environment**: `act <env_name>` or `activate <env_name>`
- **Deactivate the current environment**: `deact` or `deactivate`
- **Remove an existing environment**: `rmenv <env_name>`
- **List all environments**: `lsenv`

These commands allow you to manage multiple Python versions and their dependencies across different projects easily.

## Customizing Your Setup

Feel free to modify the scripts or add new functionalities to better suit your workflow.

## Contributing

Contributions are welcome! If you have improvements or bug fixes, please open a pull request or an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.