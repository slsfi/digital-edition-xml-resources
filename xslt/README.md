# XSLT stylesheets for SLS digital editions

The `xslt/` folder contains XSLT stylesheets for transforming XML documents to other formats in SLS digital editions. The folder should be copied to the root of the files repositories of digital edition projects, to make the stylesheets accessible to the digital edition API, which runs the transformations.

Brief descriptions of the stylesheets in the subfolders can be found below. More detailed descriptions can be found in the actual stylesheets.

> [!NOTE]
> The stylesheets are written in XSLT 3.0 and need an XSLT 3.0 processor, like [Saxon](https://www.saxonica.com/), to run.

## XSLT resources

- [W3C spec: XSL Transformations (XSLT) Version 3.0](https://www.w3.org/TR/xslt-30/)
- [W3C spec: XPath and XQuery Functions and Operators 3.1](https://www.w3.org/TR/xpath-functions-31/)
- [Saxon 12 docs: XSLT elements reference](https://www.saxonica.com/html/documentation12/xsl-elements/index.html)

## Stylesheet descriptions

### `xslt/modules/`

These “module” stylesheets operate in specific modes and must be imported and invoked by a “main” stylesheet by applying templates in the module’s mode, for example:

```xml
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

### `xslt/publisher/`

These stylesheets are used by the publisher script in the digital edition API to, for instance, create “web versions” of the TEI XML documents in a project. The web XML documents can be regarded as preprocessed versions of the source documents. They are used for transformations to HTML for the websites. The “publisher” stylesheets utilise the XSLT modules in `xslt/modules/`. The filenames of the main stylesheets are fixed and must not be changed:

- `generate-web-xml-com.xsl`
- `generate-web-xml-est.xsl`
- `generate-web-xml-ms.xsl`

### `xslt/`

The stylesheets in this folder are related to transforming the “web” TEI XML documents into HTML and other formats for the project website. The main stylesheets in the folder are directly used by the [Digital Edition API](https://github.com/slsfi/digital_edition_api) for live transformations. The filenames of the main stylesheets are fixed and must not be changed.

Stylesheets in the folder:

#### `est.xsl`

Main stylesheet for transforming a preprocessed reading-text TEI XML document (a “web version”) to an HTML5 fragment, that can be included in a web page (does not generate a complete HTML document). Relies on several “shared” XSLT stylesheets.

#### `ms_changes.xsl`

Main stylesheet for transforming a preprocessed manuscript TEI XML document (a “web version”) to an HTML5 fragment, that can be included in a web page (does not generate a complete HTML document). Relies on several “shared” XSLT stylesheets. The manuscript changes will be visible in the result document.

#### `ms_normalized.xsl`

Main stylesheet for transforming a preprocessed manuscript TEI XML document (a “web version”) to an HTML5 fragment, that can be included in a web page (does not generate a complete HTML document). Relies on several “shared” XSLT stylesheets. Unlike when transforming with `ms_changes.xsl`, the manuscript changes will *not* be visible in the result document.

#### `required-global-variables.xsl`

Stylesheet with required common global variables. This stylesheet must be imported by the main stylesheet if any of the `shared-*.xsl` stylesheets are also imported.

#### `shared-functions.xsl`

Stylesheet with common XSLT functions in the `slsFn` namespace (`https://www.sls.fi/ns/digitaledition/functions/`). The `required-global-variables.xsl` must be imported before this stylesheet.

#### `shared-match-templates.xsl`

Stylesheet with common match templates used by `est.xsl`, `ms_changes.xsl` and `ms_normalized.xsl`. The `required-global-variables.xsl`, `shared-functions.xsl` and `shared-named-templates.xsl` must be imported before this stylesheet.

#### `shared-named-templates.xsl`

Stylesheet with common named templates. The `required-global-variables.xsl` and `shared-functions.xsl` must be imported before this stylesheet.
