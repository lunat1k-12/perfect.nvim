# nvim_temp

## Mason setup

After first launch, run `:Lazy sync` to install all plugins, then install the language servers and debug adapters:

```vim
:MasonInstall lua-language-server gopls typescript-language-server html-lsp css-lsp jdtls delve java-debug-adapter java-test
```

| Mason package | Language / purpose |
|---|---|
| `lua-language-server` | Lua LSP |
| `gopls` | Go LSP |
| `typescript-language-server` | TypeScript / JavaScript / TSX / JSX LSP |
| `html-lsp` | HTML LSP |
| `css-lsp` | CSS / SCSS / Less LSP |
| `jdtls` | Java LSP (Eclipse JDT) |
| `delve` | Go debug adapter (DAP) |
| `java-debug-adapter` | Java debug adapter (DAP) |
| `java-test` | Java test runner (JUnit) |

### Java requirements

- Java 17+ must be on `$PATH` for jdtls to start.
- Copy the formatter config into place:
  ```
  cp ~/.config/nvim/config/java-style.xml ~/.config/nvim_temp/config/java-style.xml
  ```
