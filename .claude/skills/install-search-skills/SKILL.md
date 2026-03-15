---
name: install-search-skills
description: Search for and install Claude Code skills from GitHub repositories and other sources. Use when the user wants to find new skills, browse community skills, or install a skill from a GitHub URL or repository.
user-invocable: true
argument-hint: "[search-query or github-url]"
allowed-tools: Bash, WebSearch, WebFetch, Glob, Read, Write, Grep, mcp__tavily-web-search__tavily_search
---

# Install & Search Skills

Search for Claude Code skills across GitHub and install them into your project.

## Modes

This skill operates in two modes based on the argument:

### 1. Search Mode (query string)

When the argument is a search query (not a URL):

1. **Search GitHub** for repositories containing Claude Code skills:
   ```bash
   gh search repos --limit 20 "claude skills" --sort stars
   ```

2. **Also search** for repos with `.claude/skills` directories:
   ```bash
   gh search code --limit 20 "path:.claude/skills SKILL.md"
   ```

3. **Additionally search the web** using WebSearch or tavily for:
   - `"claude code skills" site:github.com <query>`
   - `"SKILL.md" ".claude/skills" <query>`

4. **Present results** as a numbered list showing:
   - Repository name and URL
   - Stars count
   - Description
   - Number of skills found (if detectable)

5. **Ask the user** which skill(s) they want to install.

### 2. Install Mode (GitHub URL or owner/repo)

When the argument is a GitHub URL or `owner/repo` format:

1. **Inspect the repository** to find available skills:
   ```bash
   gh api repos/{owner}/{repo}/git/trees/HEAD?recursive=1 -q '.tree[] | select(.path | test("^\\.claude/skills/.*/SKILL\\.md$")) | .path'
   ```

2. **If multiple skills found**, list them and ask the user which to install.

3. **For each selected skill**, fetch and install:
   ```bash
   # Fetch the SKILL.md content
   gh api repos/{owner}/{repo}/contents/{skill_path} -q '.content' | base64 -d > /tmp/skill_preview.md
   ```

4. **Show a preview** of the skill (name, description, first 20 lines) and confirm with the user before installing.

5. **Install** by creating the skill directory and writing files:
   ```bash
   mkdir -p .claude/skills/{skill-name}
   ```
   Then write the SKILL.md and any supporting files into the directory.

6. **Also check** for supporting files alongside SKILL.md (e.g., `reference.md`, `examples.md`, templates) and install those too:
   ```bash
   gh api repos/{owner}/{repo}/contents/.claude/skills/{skill-name} -q '.[].path'
   ```

## Important Rules

- **Always preview** skill content before installing — never install blindly
- **Check for conflicts** — warn if a skill with the same name already exists in `.claude/skills/`
- **Preserve existing skills** — never overwrite without explicit user confirmation
- **Security review** — scan SKILL.md for any suspicious `allowed-tools` or bash commands before installing
- **Report what was installed** — after installation, show the skill name and how to invoke it (e.g., `/skill-name`)

## Searching Tips

When searching, try multiple strategies:
- Search by topic: `gh search repos "claude code skills authentication"`
- Search by file pattern: `gh search code "path:.claude/skills SKILL.md" language:markdown`
- Search awesome lists: look for "awesome-claude-code" repositories
- Check the official Anthropic org: `gh search repos --owner=anthropics "skills"`

## Output Format

After search:
```
Found X skills matching "query":

1. owner/repo - Skill Name
   ★ 123 | Description of what it does
   Skills: skill-a, skill-b, skill-c

2. ...

Enter number(s) to install, or provide a different URL.
```

After install:
```
Installed: skill-name
  Location: .claude/skills/skill-name/SKILL.md
  Invoke with: /skill-name
  Description: What the skill does
```
