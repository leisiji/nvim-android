Deprecated, jdtls can support android project since this [commit](https://github.com/eclipse/eclipse.jdt.ls/pull/2197)

But now it is disbabled by default, we should manually enable it:

```java
local lsp_config = {
  settings = {
    java = {
      jdt = { ls = { androidSupport = { enabled =true } } }
    }
  }
}
require("jdtls").start_or_attach(lsp_config)
```
