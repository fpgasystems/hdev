<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-program.md#sgutil-program">Back to sgutil program</a>
</p>

## sgutil program driver

<code>sgutil program driver [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Inserts or removes a driver or module into the Linux kernel.
</p>

### Flags
<code>-i, --insert <string></code>
<p>
  &nbsp; &nbsp; Full path to the .ko module to be inserted.
</p>

<code>-p, --params <string></code>
<p>
  &nbsp; &nbsp; A comma separated list of module parameters.
</p>

<code>   --remote <string></code>
<p>
  &nbsp; &nbsp; Local or remote deployment.
</p>

<code>    --remove <string></code>
<p>
  &nbsp; &nbsp; Removes an existing module.
</p>

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to use this command.
</p>