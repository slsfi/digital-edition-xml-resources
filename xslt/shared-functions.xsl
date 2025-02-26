<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<xsl:function name="slsFn:get-heading-level" as="xs:integer">
	<!-- * Get the current heading level from the passed context item
	       by calculating the number of ancestor <div> or <body>
	       elements with <head> children. -->
		<xsl:param name="context-item" as="node()"/>
		<xsl:sequence select="slsFn:get-heading-level($context-item, 0)"/>
	</xsl:function>

	<xsl:function name="slsFn:get-heading-level" as="xs:integer">
	<!-- * Get the current heading level from the passed context item
	       by calculating the number of ancestor <div> or <body>
	       elements with <head> children. The result is offset by the
	       passed offset amount. -->
		<xsl:param name="context-item" as="node()"/>
		<xsl:param name="offset" as="xs:integer"/>
		<xsl:sequence select="count($context-item/ancestor::tei:div[tei:head] |
		                            $context-item/ancestor::tei:body[tei:head]
		                            ) + (if ($offset gt 0) then $offset else 0)"/>
	</xsl:function>

</xsl:stylesheet>