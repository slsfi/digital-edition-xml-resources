<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!--
	XSLT Module: remove-comment-anchors.xsl
	Version: 1.0.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-02-13
	Changes:
		- 2025-02-13: v1.0.0

	Description:
	This XSLT module removes `<anchor>` elements with `@xml:id` attributes starting
	with `start` or `end` from the input XML. All other nodes and attributes are
	preserved in the output.

	Key Features:
	- Operates in the `remove-comment-anchors` mode with `on-no-match="shallow-copy"`,
	  ensuring that unmatched nodes are copied to the output without modification.

	Usage:
	Import or include this module in a main XSLT stylesheet and apply templates 
	using the `remove-comment-anchors` mode to execute the transformation.
	-->

	<!-- Declare processing mode for this module -->
	<xsl:mode name="remove-comment-anchors" on-no-match="shallow-copy"/>

	<!-- Suppress <anchor> elements with @xml:id values starting with
	     'start' or 'end' -->
	<xsl:template match="tei:anchor[starts-with(@xml:id, 'start') or starts-with(@xml:id, 'end')]" mode="remove-comment-anchors"/>

</xsl:stylesheet>