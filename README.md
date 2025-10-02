# ai-shell-helper 🚀

A simple CLI that translates natural language into shell commands using AI. Just type what you want to do in plain English!

---
## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Hack-a-tons/ai-shell-helper.git
   cd ai-shell-helper
   ```

2. **Set up your Azure OpenAI credentials:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your Azure OpenAI API key and endpoint.

3. **Create the alias:**
   ```bash
   ./setup.sh
   ```
   Copy and paste the alias command it shows you.

4. **Start using it:**
   ```bash
   a list my files
   a how big are my files
   a where am i
   ```

---
## ✨ Demo

```bash
$ a list my files
> ls
a		README.md	scripts		setup.sh

$ a how big are my files
> du -sh *
4.0K	a
4.0K	README.md
4.0K	scripts
4.0K	setup.sh

$ a where am i
> pwd
/Users/dbystruev/Downloads/GitHub/Hack-a-tons/ai-shell-helper
```

---
## 📋 Features

* **Natural Language to Command:** Just type what you want to do - no need to remember complex syntax
* **Instant Execution:** Shows the command in color, then runs it automatically
* **Context-Aware:** Generates commands appropriate for your OS and shell
* **Powered by GPT-4.1:** Uses Azure OpenAI API for accurate command generation
* **Ultra-Simple:** Just one letter `a` followed by your request

---
## ⚙️ How It Works

The `a` command takes your natural language query and:

1. Sends it to Azure OpenAI with a specialized prompt for shell command generation
2. Extracts the clean command from the JSON response
3. Displays the command in cyan color with a `>` prefix
4. Executes the command automatically

---
## 🔧 Configuration

You need three environment variables in your `.env` file:

- `AZURE_API_VERSION` - API version (usually `2025-01-01-preview`)
- `OPENAI_API_KEY` - Your Azure OpenAI API key
- `OPENAI_ENDPOINT` - Your Azure OpenAI endpoint URL

---
## 💡 More Examples

* `a show my current git branch`
* `a find all markdown files modified today`
* `a create a backup of this directory`
* `a what processes are using port 3000`
* `a compress the src folder`

---
## 📄 License

This project is licensed under the MIT License.
