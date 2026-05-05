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
	*        This XSLT document defines XSLT 3.0 functions in the `slsFn`
	*        namespace https://www.sls.fi/ns/digitaledition/functions/ for
	*        converting selected inline TEI markup into HTML fragment strings.
	*
	*        The functions are intended for metadata transformations where a
	*        TEI element, currently most often a bibliographic source element,
	*        must be written into a string value while preserving simple inline
	*        semantics. Text is whitespace-normalised and HTML-escaped,
	*        <ref target="..."> is rendered as an <a href="..."> string, and
	*        <title> inside a <bibl> wrapper is rendered as a <cite> string.
	*        Other elements are unwrapped and processed recursively.
	*
	*    Usage:
	*        Import this stylesheet and call the entry point function
	*        slsFn:tei-inline-html() with the TEI element whose inline content
	*        should be serialised:
	*
	*            <xsl:import href="shared-tei-to-html-string-functions.xsl"/>
	*
	*            <xsl:variable name="source" as="xs:string?"
	*                          select="slsFn:tei-inline-html($bibl)"/>
	*
	*        For example, slsFn:tei-inline-html($bibl) can return a string
	*        such as:
	*
	*            In <cite>Book title</cite>,
	*            <a href="https://example.org/">related source</a>.
	*
	*    Dependencies:
	*        None.
	*
	******************************************************************* -->


	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:tei-inline-html" as="xs:string?">
	<!-- * Entry point for converting one TEI element's inline content to an
	     * HTML fragment string.
	     * The element itself is not rendered; its child nodes are serialised
	     * with slsFn:tei-node-to-html() and concatenated.
	     * The outer result is whitespace-normalised.
	     * Returns the empty sequence when the element parameter is empty. * -->
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
	<!-- * Internal helper that serialises one node to an HTML fragment string.
		 * The wrapper parameter is the TEI element whose inline content is being
	     * serialised, and is used for context-dependent output.
	     * Text nodes are returned as escaped, whitespace-normalised text.
	     * tei:ref elements with @target are returned as HTML <a> strings.
	     * tei:ref elements without @target are unwrapped to their text content.
	     * tei:title elements in a tei:bibl wrapper are returned as HTML <cite>
	     * strings.
	     * Other elements are unwrapped and processed recursively.
	     * Other node types are ignored. * -->
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
	<!-- * Internal helper that serialises one TEI text node as HTML-safe
	     * character data.
	     * Internal whitespace is collapsed.
	     * Whitespace-only text nodes between two element siblings are treated as
	     * a single word-boundary space.
	     * Leading boundary whitespace is preserved after an element sibling
	     * unless the text starts with punctuation.
	     * Trailing boundary whitespace is preserved before an element sibling.
	     * The resulting text is escaped with slsFn:escape-html-text(). * -->
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
	<!-- * Escapes &, < and > for use in HTML character data inside an
	     * HTML fragment string.
	     * Empty input is treated as an empty string. * -->
	    <xsl:param name="text" as="xs:string?"/>
	
	    <xsl:sequence select="
	        string($text)
	            => replace('&amp;', '&amp;amp;')
	            => replace('&lt;', '&amp;lt;')
	            => replace('&gt;', '&amp;gt;')
	    "/>
	</xsl:function>


	<xsl:function name="slsFn:escape-html-attribute" as="xs:string">
	<!-- * Escapes &, <, >, double quotes and single quotes for use in an
	     * HTML attribute value inside an HTML fragment string.
	     * Empty input is treated as an empty string. * -->
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
