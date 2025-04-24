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
	*
	*    Version: 1.1.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-02-13
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.1.0 (2025-04-24)
	*             - Added an internal post-processing mode for cleanup of
	*               whitespace and superfluous <lb/> elements.
	*             - Force remove <lb/> elements in `preserve-lb-breaks`
	*               mode from specific contexts that don’t support <lb/>.
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
	*        - force removes <lb @break/> elements from certain contexts
	*          that don’t support them, duplicating the `remove-lb-breaks`
	*          behaviour; currently this comprises <lb @break/> elements:
	*             - in an <add> which is displayed above or below the
	*               text baseline,
	*             - in a <del> in a <subst> where the <add> is displayed
	*               above or below the text baseline.
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

	<!-- * Main modes of the module. * -->
	<xsl:mode name="preserve-lb-breaks"/>
	<xsl:mode name="remove-lb-breaks"/>
	
	<!-- * Internal modes of the module. * -->
	<xsl:mode name="preserve-lb-core" on-no-match="shallow-copy"/>
	<xsl:mode name="remove-lb-core" on-no-match="shallow-copy"/>
	<xsl:mode name="lb-postprocessing" on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Entry points for mode processing. Each entry mode is split into
	     * two internal modes, the latter one for post-processing. * -->
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


	<!-- * Character elements. * -->
	<xsl:template match="tei:c[@function eq 'addForHyphenation'
	                           or @function eq 'removeForHyphenation']"
	              mode="remove-lb-core">
		<xsl:if test="@function eq 'removeForHyphenation'">
			<!-- * Show content when word not hyphenated. * -->
			<xsl:apply-templates mode="#current"/>
		</xsl:if>
		<!-- * If @function eq 'addForHyphenation', do nothing, which
		     * means removing the element and its content because it
		     * is only shown when the word is hyphenated. * -->
	</xsl:template>

	<xsl:template match="tei:c[@function eq 'addForHyphenation'
	                           or @function eq 'removeForHyphenation']"
	              mode="preserve-lb-core">
		<xsl:variable name="force-remove" as="xs:boolean"
		              select="slsFn:force-remove-lb(.)"/>

		<xsl:if test="not($force-remove)">
			<xsl:if test="@function eq 'addForHyphenation'">
				<!-- * Show content when word hyphenated. * -->
				<xsl:apply-templates mode="#current"/>
			</xsl:if>
			<!-- * If @function eq 'removeForHyphenation', do nothing,
			     * which means removing the element and its content
			     * because it is only shown when the word is not
			     * hyphenated. -->
		</xsl:if>
		<xsl:if test="$force-remove">
			<!-- * Duplicate the behaviour of the `remove-lb-core` mode. * -->
			<xsl:if test="@function eq 'removeForHyphenation'">
				<!-- * Show content when word not hyphenated. * -->
				<xsl:apply-templates mode="#current"/>
			</xsl:if>
			<!-- * If @function eq 'addForHyphenation', do nothing, which
			     * means removing the element and its content because it
			     * is only shown when the word is hyphenated. * -->
		</xsl:if>
	</xsl:template>


	<!-- * Punctuation character elements: the element is removed but
	     * content retained in both modes. * -->
	<xsl:template match="tei:pc" mode="preserve-lb-core remove-lb-core">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>


	<!-- * Line beginning elements with @break. * -->
	<xsl:template match="tei:lb[@break eq 'line' or @break eq 'word']"
	              mode="remove-lb-core">
		<xsl:call-template name="convert-break"/>
	</xsl:template>

	<xsl:template match="tei:lb[@break eq 'line' or @break eq 'word']"
	              mode="preserve-lb-core">
		<xsl:variable name="force-remove" as="xs:boolean"
		              select="slsFn:force-remove-lb(.)"/>

		<xsl:if test="not($force-remove)">
			<!-- * Replace with a <lb/> without attributes. * -->
			<xsl:element name="lb" namespace="{namespace-uri()}"/>
		</xsl:if>
		<xsl:if test="$force-remove">
			<xsl:call-template name="convert-break"/>
		</xsl:if>
	</xsl:template>


	<!-- * Match text nodes whose immediate following sibling is
	     * <lb @break>, and remove any trailing whitespace and hyphen
	     * from the text node. * -->
	<xsl:template match="text()[
		following-sibling::node()[1][self::tei:lb[@break]]
	]" mode="remove-lb-core">
		<xsl:value-of select="slsFn:strip-trailing-whitespace-and-hyphen(.)"/>
	</xsl:template>
	
	<!-- * In the preserve-lb-core mode, remove any trailing whitespace
	     * and hyphen from the text node if force-remove condition applies.
	     * If it doesn’t and the text node is the first child node of a
	     * <p>, remove the node if it contains only whitespace. Otherwise,
	     * just output the node as it is. * -->
	<xsl:template match="text()[
		following-sibling::node()[1][self::tei:lb[@break]]
	]" mode="preserve-lb-core">
		<xsl:variable name="force-remove" as="xs:boolean"
		              select="slsFn:force-remove-lb(.)"/>

		<xsl:sequence
			select="if ($force-remove)
		                then slsFn:strip-trailing-whitespace-and-hyphen(.)
		            else if (not($force-remove)
		                     and position() eq 1
	                         and parent::tei:p)
		                then slsFn:strip-whitespace-node(.)
		            else
		                copy-of(.)"/>
	</xsl:template>


	<!-- * Remove text nodes immediately after opening <p> tags that
	     * aren’t followed by <lb @break/> elements and that consist
	     * only of whitespace. * -->
	<xsl:template match="text()[
		position() eq 1
	    and parent::tei:p
	    and not(following-sibling::node()[1][self::tei:lb[@break]])
    ]" mode="preserve-lb-core remove-lb-core">
		<xsl:sequence select="slsFn:strip-whitespace-node(.)"/>
	</xsl:template>


	<!-- * Post-processing templates. * -->

	<!-- * Remove <lb/> elements that are the first child nodes of <p>
	     * parent elements. * -->
	<xsl:template match="tei:p/tei:lb[not(preceding-sibling::text())][1]"
	              mode="lb-postprocessing"/>

	<xsl:template match="tei:p/element(*)[
		not(preceding-sibling::text())
	]/tei:lb[not(preceding-sibling::text())][1]"
	              mode="lb-postprocessing"/>



	<!-- * NAMED TEMPLATES ******************************************** -->

	<xsl:template name="convert-break">
		<xsl:if test="@break eq 'line'
		              and preceding-sibling::text()[normalize-space()]">
			<!-- * Output a space if <lb/> is preceded by any non-empty
			     * text node. * -->
			<xsl:text> </xsl:text>
		</xsl:if>
		<!-- * If @break eq 'word', do nothing, which means removing
		     * the element. * -->
	</xsl:template>



	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:strip-trailing-whitespace-and-hyphen"
	              as="xs:string">
	<!-- * Function for removing trailing whitespace (space, tab, newline,
	     * carriage return) and remove a single trailing hyphen if
	     * present. * -->
		<xsl:param name="text" as="xs:string"/>

		<!-- * First, remove trailing whitespace. * -->
		<xsl:variable name="no-trailing-ws"
		              select="replace($text, '[ \t\r\n]+$', '')"/>
		<!-- * Then remove a single trailing hyphen if present. * -->
		<xsl:sequence select="replace($no-trailing-ws, '-$', '')"/>
	</xsl:function>


	<xsl:function name="slsFn:strip-whitespace-node" as="xs:string?">
	<!-- * Function that returns an empty sequence if the input string
	     * contains only whitespace, otherwise it returns the input
	     * string as a sequence. * -->
		<xsl:param name="text" as="xs:string"/>

		<xsl:sequence select="if (normalize-space($text) = '')
		                          then ()
		                      else $text"/>
	</xsl:function>


	<xsl:function name="slsFn:force-remove-lb" as="xs:boolean">
	<!-- * Function that returns true if the passed context node has
	     * an ancestor that forces <lb> elements to be removed from its
	     * descendants. Currently this applies if the context node is:
	     * - in an <add> which is displayed above or below the text
	     *   baseline,
	     * - in a <del> in a <subst> where the <add> is displayed above
	     *   or below the text baseline. * -->
		<xsl:param name="context-node" as="node()"/>
		
		<xsl:sequence select="
			if (
				$context-node/ancestor::tei:add[not(@place)
					or @place = ('sublinear', 'other')
					or @type eq 'choice']
				or
				$context-node/ancestor::tei:del[
					parent::tei:subst[tei:add[not(@place)
						or @place = ('sublinear', 'other')]
					]
				]
			) then true() else false()
		"/>
	</xsl:function>

</xsl:stylesheet>