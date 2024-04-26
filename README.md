# Virtualenv Setup

This repository contains a personal virtualenv setup using asdf and direnv to replace Anaconda for managing Python environments. It's designed to be simple, efficient, and flexible.

## Installation

Follow these steps to install and configure the virtualenv setup on your system:

1. **Clone the Repository**
   First, clone this repository into the `.virtualenvs` directory in your home folder by using the following command:
   ```bash
   git clone https://your-repository-url.git ~/.virtualenvs
   ```

2. **Environment Variable Setup**
   You'll need to set an environment variable to use this virtualenv setup. Add the following line to your shell configuration file (`.zshrc` or `.bashrc`):
   ```bash
   export ENV_HOME="$HOME/.virtualenvs"
   ```

3. **Source the Virtualenv Script**
   To initialize the virtualenv configuration, source the `virtualenv.sh` script from your shell configuration file. Add this line to the end of your `.zshrc` or `.bashrc` to make sure it's executed every time a new shell is started:
   ```bash
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

Feel free to modify the scripts or add new functionalities to suit your workflow better.

## Contributing

Contributions are welcome! If you have improvements or bug fixes, please open a pull request or an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
