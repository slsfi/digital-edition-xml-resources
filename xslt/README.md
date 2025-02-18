# XSLT stylesheets for SLS digital editions

The `xslt/` folder contains XSLT stylesheets for transforming XML documents to other formats in SLS digital editions. The folder should be copied to the root of the files repositories of digital edition projects, to make the stylesheets accessible to the digital edition API, which runs the transformations.

Brief descriptions of the stylesheets in the subfolders (more detailed descriptions can be found in the stylesheets themselves):

## `modules/`

These “module” stylesheets operate in specific modes and must be imported and invoked by a “master” stylesheet by applying templates in the module’s mode, for example:

```
<!-- Import module -->
<xsl:import href="modules/add-numbering.xsl"/>

<!-- Entry point -->
<xsl:template match="/">

  <!-- Store the module’s result in a variable -->
  <xsl:variable name="add-numbering-result">
    <xsl:apply-templates select="." mode="add-numbering"/>
  </xsl:variable>

  <!-- Output the variable -->
  <xsl:sequence select="$add-numbering-result"/>
</xsl:template>
```

## `publisher/`


