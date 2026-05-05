<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: shared-tei-to-html-string-functions.xsl
	*
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2026-05-05
	*    Licence: CC-BY 4.0 (Attribution 4.0 International),
	*             https://creativecommons.org/licenses/by/4.0/
	*
	*    Changes:
	*        v1.0.0 (2026-05-05)
	*
	*    Description:
	*        This XSLT document defines functions in the `slsFn` namespace
	*        https://www.sls.fi/ns/digitaledition/functions/ for transforming
	*        TEI elements into inline HTML strings.
	*
	*    Dependencies:
	*        None.
	*
	******************************************************************* -->


	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:tei-inline-html" as="xs:string?">
	<!-- * This is the entry point function for the feature in this file.
		 * Serialises the inline content of a TEI element as an HTML string.
		 * Text nodes are whitespace-normalised with boundary spaces around
	     * adjacent inline elements.
	     * tei:ref elements with target attributes are converted to HTML anchor tags.
	     * Other elements are processed recursively by serialising their child nodes.
	     * The function returns a string for use in map entries that are later
	     * serialised as JSON. * -->
		<xsl:param name="element" as="element()?"/>
	
		<xsl:sequence select="
		    if (empty($element))
		        then ()
		    else
	            string-join(
	                for $node in $element/node()
	                return slsFn:tei-node-to-html($node, $element),
	                ''
	            ) => normalize-space()
		    "/>
	</xsl:function>


	<xsl:function name="slsFn:tei-node-to-html" as="xs:string">
		<!-- * Serialises a TEI node as an HTML string.
		 * `wrapper` is the ancestor element.
	     * Text nodes are returned as escaped, normalised text.
	     * tei:ref elements are returned as HTML anchor strings when they have
	     * a target attribute.
	     * tei:ref elements without target attributes are returned as plain text.
	     * tei:title elements in tei:bibl wrappers are returned as HTML citation
	     * strings.
	     * Other elements are processed recursively by serialising their child nodes.
	     *  * -->
	    <xsl:param name="node" as="node()"/>
		<xsl:param name="wrapper" as="element()"/>
	
	    <xsl:choose>
	        <xsl:when test="$node instance of text()">
	            <xsl:sequence select="slsFn:tei-text-to-html($node)"/>
	        </xsl:when>
	
	        <xsl:when test="$node instance of element(tei:ref)">
	            <xsl:variable name="content" as="xs:string"
	                          select="slsFn:tei-inline-html($node)"/>
	
	            <xsl:sequence select="
	                if ($node/@target)
	                    then
	                        '&lt;a href=&quot;' ||
	                        slsFn:escape-html-attribute(string($node/@target)) ||
	                        '&quot;&gt;' ||
	                        $content ||
	                        '&lt;/a&gt;'
	                else
	                    $content
	            "/>
	        </xsl:when>

			<xsl:when test="$node instance of element(tei:title) and
				            $wrapper instance of element(tei:bibl)">
				<xsl:sequence select="
					'&lt;cite&gt;' || slsFn:tei-inline-html($node) || '&lt;/cite&gt;'
				"/>
			</xsl:when>

	        <xsl:when test="$node instance of element()">
	            <xsl:sequence select="
	                string-join(
	                    for $child in $node/node()
	                    return slsFn:tei-node-to-html($child, $wrapper),
	                    ''
	                )
	            "/>
	        </xsl:when>

	        <xsl:otherwise>
	            <xsl:sequence select="''"/>
	        </xsl:otherwise>
	    </xsl:choose>
	</xsl:function>


	<xsl:function name="slsFn:tei-text-to-html" as="xs:string">
		<!-- * Serialises a TEI text node as HTML-safe text.
	     * Internal whitespace is collapsed.
	     * Whitespace-only text nodes between two element siblings are treated as
	     * a single word-boundary space.
	     * Leading boundary whitespace is preserved after an element sibling unless
	     * the text starts with punctuation.
	     * Trailing boundary whitespace is preserved before an element sibling.
	     * The text content is HTML-escaped. * -->
	    <xsl:param name="node" as="text()"/>
	
	    <xsl:variable name="raw" as="xs:string"
	                  select="string($node)"/>
	
	    <xsl:variable name="text" as="xs:string"
	                  select="normalize-space($raw)"/>
	
	    <xsl:variable name="previous-is-element" as="xs:boolean"
	                  select="$node/preceding-sibling::node()[1] instance of element()"/>
	
	    <xsl:variable name="next-is-element" as="xs:boolean"
	                  select="$node/following-sibling::node()[1] instance of element()"/>
	
	    <xsl:variable name="starts-with-whitespace" as="xs:boolean"
	                  select="matches($raw, '^\s')"/>
	
	    <xsl:variable name="ends-with-whitespace" as="xs:boolean"
	                  select="matches($raw, '\s$')"/>
	
	    <xsl:variable name="starts-with-punctuation" as="xs:boolean"
	                  select="matches($text, '^[,.;:!?)]')"/>
	
	    <xsl:sequence select="
	        if ($text eq '') then
	            if ($previous-is-element and $next-is-element)
	                then ' '
	            else
	                ''
	        else
	            slsFn:escape-html-text(
	                (
	                    if ($previous-is-element
	                        and $starts-with-whitespace
	                        and not($starts-with-punctuation))
	                    then ' '
	                    else ''
	                ) ||
	                $text ||
	                (
	                    if ($next-is-element and $ends-with-whitespace)
	                    then ' '
	                    else ''
	                )
	            )
	    "/>
	</xsl:function>


	<xsl:function name="slsFn:escape-html-text" as="xs:string">
		<!-- * Escapes text for use in HTML character data in an HTML string. * -->
	    <xsl:param name="text" as="xs:string?"/>
	
	    <xsl:sequence select="
	        string($text)
	            => replace('&amp;', '&amp;amp;')
	            => replace('&lt;', '&amp;lt;')
	            => replace('&gt;', '&amp;gt;')
	    "/>
	</xsl:function>


	<xsl:function name="slsFn:escape-html-attribute" as="xs:string">
		<!-- * Escapes text for use in an HTML attribute value in an HTML string. * -->
	    <xsl:param name="text" as="xs:string?"/>

	    <xsl:sequence select="
	        string($text)
	            => replace('&amp;', '&amp;amp;')
	            => replace('&lt;', '&amp;lt;')
	            => replace('&gt;', '&amp;gt;')
	            => replace(codepoints-to-string(34), '&amp;quot;')
	            => replace(codepoints-to-string(39), '&amp;#39;')
	    "/>
	</xsl:function>


</xsl:stylesheet>