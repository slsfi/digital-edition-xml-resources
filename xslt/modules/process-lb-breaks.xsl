<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="tei xs slsFn"
>

	<!--
	XSLT Module: process-lb-breaks.xsl
	Version: 1.1.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-02-13
	Changes:
		- 2025-04-07: v1.1.0
			- Added an internal post-processing mode for cleanup of whitespace
			  and superfluous <lb/> elements.
		- 2025-02-13: v1.0.0

	Description:
	This XSLT module processes TEI-encoded documents and transforms <lb> elements
	with @break attributes and certain sibling nodes. It operates in either the
	`preserve-lb-breaks` or `remove-lb-breaks` mode with
	`on-no-match="shallow-copy"`, ensuring that unmatched nodes are copied to the
	output without modification.

	In the `preserve-lb-breaks` mode it:
	- converts <lb @break/> elements to <lb/>
	- unwraps <c function="addForHyphenation"> elements
	- removes <c function="removeForHyphenation"> elements
	- unwraps <pc> elements

	In the `remove-lb-breaks` mode it:
	- converts <lb break="line"/> elements to space characters
	- removes <lb break="word"/> elements
	- removes trailing whitespace and hyphen from text nodes immediately
	  before <lb @break/> elements
	- removes <c function="addForHyphenation"> elements
	- unwraps <c function="removeForHyphenation"> elements
	- unwraps <pc> elements

	Typically you would use the `preserve-lb-breaks` mode for generating
	manuscripts to web XML files, and the `remove-lb-breaks` mode for
	generating reading-text (established text) to web XML files.

	Usage:
	Import or include this module in a main XSLT stylesheet and apply templates using
	either the `preserve-lb-breaks` or `remove-lb-breaks` mode to execute the
	transformation.
	-->

	<!-- Declare processing modes for this module -->
	<xsl:mode name="preserve-lb-breaks"/>
	<xsl:mode name="remove-lb-breaks"/>
	
	<!-- Declare an internal modes for this module -->
	<xsl:mode name="preserve-lb-core" on-no-match="shallow-copy"/>
	<xsl:mode name="remove-lb-core" on-no-match="shallow-copy"/>
	<xsl:mode name="lb-postprocessing" on-no-match="shallow-copy"/>


	<!-- Entry points for mode processing. Each entry mode is split into
	     two internal modes, the latter one for post-processing. -->
	<xsl:template match="node()" mode="preserve-lb-breaks">
		<xsl:variable name="intermediate">
			<xsl:apply-templates select="." mode="preserve-lb-core"/>
		</xsl:variable>
		<xsl:apply-templates select="$intermediate" mode="lb-postprocessing"/>
	</xsl:template>
	
	<xsl:template match="node()" mode="remove-lb-breaks">
		<xsl:variable name="intermediate">
			<xsl:apply-templates select="." mode="remove-lb-core"/>
		</xsl:variable>
		<xsl:apply-templates select="$intermediate" mode="lb-postprocessing"/>
	</xsl:template>


	<!-- Function to remove trailing whitespace (space, tab, newline,
	     carriage return) and remove a single trailing hyphen if present. -->
	<xsl:function name="slsFn:strip-trailing-whitespace-and-hyphen" as="xs:string">
		<xsl:param name="text" as="xs:string"/>
		<!-- First, remove trailing whitespace -->
		<xsl:variable name="no-trailing-ws" select="replace($text, '[ \t\r\n]+$', '')"/>
		<!-- Then remove a single trailing hyphen if present -->
		<xsl:sequence select="replace($no-trailing-ws, '-$', '')"/>
	</xsl:function>

	<!-- Function that returns an empty sequence if the input string contains
	     only whitespace, otherwise it returns the input string as a sequence. -->
	<xsl:function name="slsFn:strip-whitespace-node" as="xs:string?">
		<xsl:param name="text" as="xs:string"/>
		<xsl:sequence select="if (normalize-space($text) = '') then () else $text"/>
	</xsl:function>

	<!-- Character elements -->
	<xsl:template match="tei:c[@function eq 'addForHyphenation' or @function eq 'removeForHyphenation']"
	              mode="remove-lb-core">
		<xsl:if test="@function eq 'removeForHyphenation'">
			<!-- Show content when word not hyphenated -->
			<xsl:apply-templates mode="#current"/>
		</xsl:if>
		<!-- If @function eq 'addForHyphenation', do nothing, which means
		     removing the element and its content because it is only shown
		     when the word is hyphenated. -->
	</xsl:template>

	<xsl:template match="tei:c[@function eq 'addForHyphenation' or @function eq 'removeForHyphenation']"
	              mode="preserve-lb-core">
		<xsl:if test="@function eq 'addForHyphenation'">
			<!-- Show content when word hyphenated -->
			<xsl:apply-templates mode="#current"/>
		</xsl:if>
		<!-- If @function eq 'removeForHyphenation', do nothing, which means
		     removing the element and its content because it is only shown
		     when the word is not hyphenated. -->
	</xsl:template>

	<!-- Punctuation character elements: the element is removed but content retained -->
	<xsl:template match="tei:pc" mode="preserve-lb-core remove-lb-core">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>

	<!-- Line beginning elements with @break -->
	<xsl:template match="tei:lb[@break eq 'line' or @break eq 'word']" mode="remove-lb-core">
		<xsl:if test="@break eq 'line' and preceding-sibling::text()[normalize-space()]">
			<!-- Output a space if <lb/> is preceded by any non-empty text node -->
			<xsl:text> </xsl:text>
		</xsl:if>
		<!-- If @break eq 'word', do nothing, which means removing the element -->
	</xsl:template>

	<xsl:template match="tei:lb[@break eq 'line' or @break eq 'word']" mode="preserve-lb-core">
		<!-- Replace with a <lb/> without attributes -->
		<xsl:element name="lb" namespace="{namespace-uri()}"/>
	</xsl:template>

	<!-- Match text nodes whose immediate following sibling is <lb @break>,
	     and remove any trailing whitespace and hyphen from the text node -->
	<xsl:template match="text()[following-sibling::node()[1][self::tei:lb[@break]]]" mode="remove-lb-core">
		<xsl:value-of select="slsFn:strip-trailing-whitespace-and-hyphen(.)"/>
	</xsl:template>

	<!-- Remove text nodes immediately after opening <p> tags that consist
	     only of whitespace. -->
	<xsl:template match="text()[position() eq 1
	                     and parent::tei:p
	                     and not(following-sibling::node()[1][self::tei:lb[@break]])]"
	              mode="remove-lb-core">
		<xsl:sequence select="slsFn:strip-whitespace-node(.)"/>
	</xsl:template>

	<xsl:template match="text()[position() eq 1 and parent::tei:p]"
	              mode="preserve-lb-core">
		<xsl:sequence select="slsFn:strip-whitespace-node(.)"/>
	</xsl:template>

	
	<!-- Post-processing templates -->

	<!-- Remove <lb/> elements that are the first child nodes of <p>
	     parent elements.-->
	<xsl:template match="tei:p/tei:lb[not(preceding-sibling::text())][1]"
	              mode="lb-postprocessing"/>

	<xsl:template match="tei:p/element(*)[not(preceding-sibling::text())]/tei:lb[not(preceding-sibling::text())][1]"
	              mode="lb-postprocessing"/>
	

</xsl:stylesheet>