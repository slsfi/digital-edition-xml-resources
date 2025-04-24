<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: move-comment-anchors.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-01-09
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-01-09)
	*
	*    Description:
	*        This XSLT module processes specific TEI elements
	*        (`<persName>`, `<placeName>`, `<title>`, `<reg>`, `<foreign>`,
	*        and `<rs>`) to "move" `<anchor>` elements with `@xml:id`
	*        attributes starting with `end` outside their parent elements.
	*        This is because the commentary tool Edith sometimes places
	*        anchor end elements of comments wrongly.
	*
	*    Key Features:
	*        - Operates in the `move-comment-anchors` mode with
	*          `on-no-match="shallow-copy"`, ensuring that unmatched nodes
	*          are copied to the output without modification.
	*        - Preserves all attributes and child nodes of matched elements,
	*          except for the targeted `<anchor>` elements, which are moved
	*          outside the parent.
	*
	*    Usage:
	*        Import or include this module in a main XSLT stylesheet and
	*        apply templates using the `move-comment-anchors` mode to
	*        execute the transformation.
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS ****************************************** -->

	<xsl:mode name="move-comment-anchors" on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Match <persName>, <placeName>, <title>, <reg>, <foreign>, and
	     * <rs> elements. * -->
	<xsl:template match="tei:persName | tei:placeName | tei:title | tei:reg | tei:foreign | tei:rs" mode="move-comment-anchors">
		<xsl:copy>
			<!-- * Copy all attributes * -->
			<xsl:apply-templates select="@*" mode="move-comment-anchors"/>
			<!-- * Copy all children except <anchor/> with @xml:id starting
			     * with "end". * -->
			<xsl:apply-templates select="node()[not(self::tei:anchor and starts-with(@xml:id, 'end'))]" mode="move-comment-anchors"/>
		</xsl:copy>
		<!-- * Move <anchor/> elements with @xml:id starting with "end"
		     * outside the parent. * -->
		<xsl:apply-templates select="node()[self::tei:anchor and starts-with(@xml:id, 'end')]" mode="move-comment-anchors"/>
	</xsl:template>

</xsl:stylesheet>