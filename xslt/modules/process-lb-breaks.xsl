<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="tei xs slsFn"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: process-lb-breaks.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-02-13
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-02-13)
	*
	*    Description:
	*        This XSLT module processes TEI-encoded documents and
	*        transforms <lb> elements with @break attributes and certain
	*        sibling nodes. It operates in either the `preserve-lb-breaks`
	*        or `remove-lb-breaks` mode with `on-no-match="shallow-copy"`,
	*        ensuring that unmatched nodes are copied to the output
	*        without modification.
	*
	*        In the `preserve-lb-breaks` mode it:
	*        - converts <lb @break/> elements to <lb/>
	*        - unwraps <c function="addForHyphenation"> elements
	*        - removes <c function="removeForHyphenation"> elements
	*        - unwraps <pc> elements
	*
	*        In the `remove-lb-breaks` mode it:
	*        - converts <lb break="line"/> elements to space characters
	*        - removes <lb break="word"/> elements
	*        - removes trailing whitespace and hyphen from text nodes
	*          immediately before <lb @break/> elements
	*        - removes <c function="addForHyphenation"> elements
	*        - unwraps <c function="removeForHyphenation"> elements
	*        - unwraps <pc> elements
	*
	*        Typically you would use the `preserve-lb-breaks` mode for
	*        generating manuscripts to web XML files, and the
	*        `remove-lb-breaks` mode for generating reading-text
	*        (established text) to web XML files.
	*
	*    Usage:
	*        Import or include this module in a main XSLT stylesheet and
	*        apply templates using either the `preserve-lb-breaks` or
	*        `remove-lb-breaks` mode to execute the transformation.
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS ****************************************** -->

	<xsl:mode name="preserve-lb-breaks" on-no-match="shallow-copy"/>
	<xsl:mode name="remove-lb-breaks" on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Character elements. * -->
	<xsl:template match="tei:c[@function eq 'addForHyphenation' or @function eq 'removeForHyphenation']" mode="remove-lb-breaks">
		<xsl:if test="@function eq 'removeForHyphenation'">
			<!-- * Show content when word not hyphenated * -->
			<xsl:apply-templates mode="#current"/>
		</xsl:if>
		<!-- * If @function eq 'addForHyphenation', do nothing, which means
		     * removing the element and its content because it is only shown
		     * when the word is hyphenated. * -->
	</xsl:template>

	<xsl:template match="tei:c[@function eq 'addForHyphenation' or @function eq 'removeForHyphenation']" mode="preserve-lb-breaks">
		<xsl:if test="@function eq 'addForHyphenation'">
			<!-- * Show content when word hyphenated * -->
			<xsl:apply-templates mode="#current"/>
		</xsl:if>
		<!-- * If @function eq 'removeForHyphenation', do nothing, which means
		     * removing the element and its content because it is only shown
		     * when the word is not hyphenated. * -->
	</xsl:template>


	<!-- * Punctuation character elements: the element is removed but
	     * content retained. * -->
	<xsl:template match="tei:pc" mode="preserve-lb-breaks remove-lb-breaks">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>


 	<!-- * Line beginning elements with @break * -->
	<xsl:template match="tei:lb[@break eq 'line' or @break eq 'word']" mode="remove-lb-breaks">
    <xsl:if test="@break eq 'line'">
      <!-- * Output a space * -->
      <xsl:text> </xsl:text>
    </xsl:if>
    <!-- * If @break eq 'word', do nothing, which means removing the element * -->
	</xsl:template>

	<xsl:template match="tei:lb[@break eq 'line' or @break eq 'word']" mode="preserve-lb-breaks">
		<!-- *Replace with a <lb/> without attributes * -->
    <xsl:element name="lb" namespace="{namespace-uri()}"/>
	</xsl:template>


 	<!-- * Match text nodes whose immediate following sibling is
  	     * <lb @break>, and remove any trailing whitespace and hyphen
  	     * from the text node. * -->
	<xsl:template match="text()[following-sibling::node()[1][self::tei:lb[@break]]]" mode="remove-lb-breaks">
		<xsl:value-of select="slsFn:strip-trailing-whitespace-and-hyphen(.)"/>
	</xsl:template>



	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:strip-trailing-whitespace-and-hyphen" as="xs:string">
	<!-- * Function to remove trailing whitespace (space, tab, newline,
	     * carriage return) and remove a single trailing hyphen if present. * -->
		<xsl:param name="text" as="xs:string"/>
		<!-- * First, remove trailing whitespace. * -->
		<xsl:variable name="no-trailing-ws" select="replace($text, '[ \t\r\n]+$', '')"/>
		<!-- * Then remove a single trailing hyphen if present. * -->
		<xsl:sequence select="replace($no-trailing-ws, '-$', '')"/>
	</xsl:function>

</xsl:stylesheet>