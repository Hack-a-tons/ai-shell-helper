# ai-shell-helper 🚀

My project for the Hack Night at GitHub! A simple CLI that translates natural language into shell commands using the power of AI.



---
## ✨ Demo

Forget trying to remember the exact syntax for `find` or `tar`. Just ask `ai-shell-helper` what you want to do.

```bash
$ ./ai-shell-helper.sh "find all markdown files in the current directory modified in the last day"

> find . -name "*.md" -mtime -1
```

```bash
$ ./ai-shell-helper.sh "list the 5 largest files here and show their size"

> ls -lS | head -n 6
```

---
## 📋 Features

* **Natural Language to Command:** Translates plain English queries into accurate, executable shell commands.
* **Context-Aware:** Uses your OS and shell type (`$SHELL`) to generate the correct command syntax for your environment.
* **Powered by GPT-4.1:** Leverages the Azure OpenAI API for high-quality command generation.
* **Lightweight:** A simple, single-file bash script that is easy to read, modify, and use.

---
## ⚙️ How It Works

The `ai-shell-helper.sh` script takes your text query as its argument. It then constructs a carefully engineered prompt for the OpenAI API.

1.  **System Prompt:** It first tells the AI model its role: to act as a shell command expert and to *only* respond with the raw command, with no extra text or explanations.
2.  **Contextual Info:** It gathers your system information (e.g., `uname -a` and `$SHELL`) and includes it in the prompt, so the AI knows whether to generate commands for `zsh` on macOS, `bash` on Linux, etc.
3.  **API Call:** The script sends the request to the Azure OpenAI endpoint.
4.  **Clean Output:** It parses the JSON response and prints the clean, executable command directly to your terminal.

---
## 🔧 Setup

Get up and running in a few steps.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Hack-a-tons/ai-shell-helper.git](https://github.com/Hack-a-tons/ai-shell-helper.git)
    cd ai-shell-helper
    ```

2.  **Configure your credentials:**
    The script reads your Azure OpenAI credentials from a `.env` file.
    ```bash
    # Create the .env file from the example
    cp .env.example .env
    ```
    Now, edit the `.env` file and add your specific API key, endpoint, and version.

3.  **Make the script executable:**
    ```bash
    chmod +x ai-shell-helper.sh
    ```

---
## 🚀 Usage

To use the helper, simply run the script with your query in quotes.

```bash
./ai-shell-helper.sh "your natural language query"
```

#### More Examples:

* `./ai-shell-helper.sh "show my current git branch"`
* `./ai-shell-helper.sh "how do I find a process that is listening on port 3000?"`
* `./ai-shell-helper.sh "create a gzipped tarball of the 'src' directory"`

---
## 💡 Future Improvements

This project was built in just a couple of hours! Here are some ideas for taking it to the next level:

* **Deeper Context:** Automatically include the current working directory (`$PWD`) and the status of the current `git` repository in the prompt for even more relevant commands.
* **Interactive Execution:** Add a `-x` or `--execute` flag to immediately run the generated command, with a confirmation safety prompt for potentially destructive commands (`rm`, `dd`, `mv`).
* **Command History:** Keep a log of previous queries and generated commands for easy recall.
* **Better Error Handling:** Add more robust error handling for API failures or empty responses from the AI.

---
## 📄 License

This project is licensed under the MIT License.
