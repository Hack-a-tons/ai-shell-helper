# ai-shell-helper 🚀

A simple CLI that translates natural language into shell commands using AI. Just type what you want to do in plain English!

*Built for the [HackerSquad Builders Hackathon](https://hackersquad.io/builders/dashboard/events/cm5vmcvou000aov0lls2pmd3e) featuring Weaviate integration for intelligent command caching.*

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
   pls list my files
   please how big are my files
   pls where am i
   ```

**Optional:** Set up Weaviate for command caching (see Configuration section below).

---
## ✨ Demo

```bash
$ pls list my files
> ls
a		README.md	scripts		setup.sh

$ please how big are my files
> du -sh *
4.0K	a
4.0K	README.md
4.0K	scripts
4.0K	setup.sh

$ pls where am i
> pwd
/Users/dbystruev/Downloads/GitHub/Hack-a-tons/ai-shell-helper
```

---
## 📋 Features

* **Natural Language to Command:** Just type what you want to do - no need to remember complex syntax
* **Instant Execution:** Shows the command in color, then runs it automatically
* **Context-Aware:** Generates commands appropriate for your OS and shell
* **Powered by GPT-4.1:** Uses Azure OpenAI API for accurate command generation
* **Ultra-Simple:** Just `pls` or `please` followed by your request

---
## ⚙️ How It Works

The `pls` or `please` command takes your natural language query and:

1. **Checks Weaviate cache** for similar previous queries (if configured)
2. If found, returns cached command instantly with green "(cached)" indicator
3. If not found, sends query to Azure OpenAI for command generation
4. Extracts the clean command from the JSON response
5. **Stores the query-command pair** in Weaviate for future use
6. Displays the command in cyan color with a `>` prefix
7. Executes the command automatically

### Weaviate Integration

Weaviate provides semantic caching that:
- **Reduces API costs** by avoiding repeated OpenAI calls
- **Improves response time** for similar queries
- **Learns from usage** - builds a personalized command database
- **Works across sessions** - cache persists between uses

Example flow:
```bash
$ pls list my files          # First time - calls OpenAI, stores in Weaviate
> ls                         # Blue text (from AI)

$ pls show my files          # Similar query - finds cached result
> ls (cached)                # Green text (from cache)
```

---
## 🔧 Configuration

You need three environment variables in your `.env` file:

- `AZURE_API_VERSION` - API version (usually `2025-01-01-preview`)
- `OPENAI_API_KEY` - Your Azure OpenAI API key
- `OPENAI_ENDPOINT` - Your Azure OpenAI endpoint URL

**Optional Weaviate caching:**
- `WEAVIATE_URL` - Weaviate instance URL (local or remote)
- `WEAVIATE_API_KEY` - Your Weaviate API key

### Weaviate Setup (Optional)

**Local setup:**
```bash
docker compose up -d
```

**Remote server setup:**
```bash
# On your remote server
docker compose up -d
# Then update WEAVIATE_URL in .env to your server's IP/domain
```

---
## 💡 More Examples

* `pls show my current git branch`
* `please find all markdown files modified today`
* `pls create a backup of this directory`
* `please what processes are using port 3000`
* `pls compress the src folder`

---
## 📄 License

This project is licensed under the MIT License.
