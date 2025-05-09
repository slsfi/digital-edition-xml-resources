<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: remove-delspans.xsl
	*    Version: 1.0.2
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-01-10
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.2 (2025-05-09)
	*             - Fix matching logic of <delSpan> and <anchor>.
	*        v1.0.1 (2025-05-06)
	*             - Fix ambiguous template matching.
	*        v1.0.0 (2025-01-10)
	*
	*    Description:
	*        Removes spans of content from a TEI-encoded XML document that
	*        are marked for deletion using <delSpan/>…<anchor/> pairs. Any
	*        content located between a <delSpan> element (with a @spanTo
	*        attribute) and a matching <anchor> (with corresponding
	*        @xml:id) is excluded from the output. The <delSpan> and
	*        <anchor> elements themselves are also removed.
	*
	*        Supports nested <delSpan>…<anchor> pairs. The pairs must be
	*        sibling elements. The starting <delSpan> or ending <anchor>
	*        of a pair must not be placed within another pair unless they
	*        both are.
	*
	*    Key Features:
	*        - Operates in the `add-numbering` mode with
	*          `on-no-match="shallow-copy"`, ensuring that unmatched nodes
	*          are copied to the output without modification.
	*        - Removes:
	*        	1. Nodes between `<delSpan>` and its corresponding
	*              `<anchor>`, as long as these marker elements are
	*              siblings.
	*        	2. The `<delSpan>` element with a valid `@spanTo`
	*              attribute.
	*        	3. The `<anchor>` element with a matching `@xml:id`
	*              attribute.
	*
	*    Usage:
	*        Import or include this module in a main XSLT stylesheet and
	*        apply templates using the "remove-delspans" mode to execute
	*        the transformation.
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS ****************************************** -->

	<xsl:mode name="remove-delspans" on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->

	<xsl:template match="node()" mode="remove-delspans">
		<xsl:choose>
			<!-- * Remove <delSpan>. * -->
			<xsl:when test="self::tei:delSpan"/>
	
			<!-- * Remove <anchor> that matches a preceding sibling
			     * <delSpan>. * -->
			<xsl:when test="self::tei:anchor[
				some $d in preceding-sibling::tei:delSpan[@spanTo]
				satisfies $d/@spanTo eq concat('#', @xml:id)
			]"/>
	
			<!-- * Remove any node between matched <delSpan> and
			     * <anchor>. * -->
			<xsl:when test="
				some $d in preceding-sibling::tei:delSpan[@spanTo]
				satisfies (
					some $a in following-sibling::tei:anchor[@xml:id]
					satisfies $d/@spanTo eq concat('#', $a/@xml:id)
				)
			"/>
			
			<!-- * Default: shallow copy the node. * -->
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>