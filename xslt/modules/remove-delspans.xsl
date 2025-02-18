<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!--
	XSLT Module: remove-delspans.xsl
	Version: 1.0.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-01-10
	Changes:
		- 2025-01-10: v1.0.0

	Description:
	This XSLT module processes TEI-encoded documents to remove all nodes located
	between `<delSpan>` elements with a `@spanTo` attribute that matches the
	`@xml:id` attribute of a subsequent `<anchor>` element. Additionally,
	the `<delSpan>` and `<anchor>` elements themselves are removed from
	the output. This transformation ensures that marked spans of deletions and
	their corresponding markers are excluded from the resulting document.

	Key Features:
	- Operates in the "remove-delspans" mode with `on-no-match="shallow-copy"`,
	  ensuring that unmatched nodes are copied to the output without modification.
	- Removes:
		1. Nodes between `<delSpan>` and its corresponding `<anchor>`.
		2. The `<delSpan>` element with a valid `@spanTo` attribute.
		3. The `<anchor>` element with a matching `@xml:id` attribute.

	Usage:
	Import or include this module in a main XSLT stylesheet and apply templates 
	using the "remove-delspans" mode to execute the transformation.
	-->

	<!-- Declare processing mode for this module -->
	<xsl:mode name="remove-delspans" on-no-match="shallow-copy"/>

	<!-- Remove nodes between <delSpan> with a @spanTo value matching a
	     @xml:id value of an <anchor> -->
	<xsl:template match="node()[preceding-sibling::tei:delSpan[@spanTo] and following-sibling::tei:anchor[concat('#', @xml:id) eq preceding-sibling::tei:delSpan[1]/@spanTo]]" mode="remove-delspans"/>

	<!-- Remove <delSpan> with a valid @spanTo -->
	<xsl:template match="tei:delSpan[@spanTo]" mode="remove-delspans"/>

	<!-- Remove <anchor> with @xml:id if it has a preceding <delSpan>
	     with matching @spanTo -->
	<xsl:template match="tei:anchor[concat('#', @xml:id) eq preceding-sibling::tei:delSpan/@spanTo]" mode="remove-delspans"/>

</xsl:stylesheet>