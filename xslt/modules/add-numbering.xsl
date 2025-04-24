<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: add-numbering.xsl
	*
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
	*        This XSLT module assigns sequential numbering to specific
	*        elements in TEI-encoded documents, such as lines of poetry,
	*        line groups in prose, and paragraphs in prose. The numbering
	*        is added as an `@n` attribute to the relevant elements,
	*        ensuring the logical structure of the document is maintained.
	*
	*    Key Features:
	*        - Operates in the `add-numbering` mode with
	*          `on-no-match="shallow-copy"`, ensuring that unmatched nodes
	*          are copied to the output without modification.
	*        - Adds line numbering to `<l>` elements within poetry texts.
	*        - Adds line group numbering (`<lg>`) and paragraph numbering
	*          (`<p>`) for prose texts.
	*        - Preserves all attributes and child nodes of the processed
	*          elements.
	*
	*    Usage:
	*        Import or include this module in a main XSLT stylesheet and
	*        apply templates using the `add-numbering` mode to execute
	*        the transformation.
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS ****************************************** -->

	<xsl:mode name="add-numbering" on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Line numbering (only in poetry):
	     * <l> that are descendants of <opener>, <note> or <floatingText>
	     * are not numbered. <l> with @part values "M", "F" and "F2" get
	     * the same number as the previous <l part="I"> or <l>
	     * element. * -->
	<xsl:template match="tei:l[ancestor::tei:text[@type eq 'poem'] and not(ancestor::tei:opener) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)]" mode="add-numbering">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="n">
				<xsl:number count="tei:l[ancestor::tei:text[@type eq 'poem'] and not(ancestor::tei:opener) and not(ancestor::tei:note) and not(ancestor::tei:floatingText) and (not(@part) or (@part ne 'M' and @part ne 'F' and @part ne 'F2'))]" level="any" from="/tei:TEI/tei:text/tei:body"/>
			</xsl:attribute>
			<xsl:apply-templates mode="add-numbering"/>
		</xsl:copy>
	</xsl:template>


	<!-- * Line group numbering (only in prose, together with
	     * paragraph numbering):
	     * <lg> that are descendants <opener>, <note> or <floatingText>
	     * are not numbered. * -->
	<xsl:template match="tei:lg[ancestor::tei:text and (not(ancestor::tei:text[@type]) or ancestor::tei:text[@type ne 'poem']) and not(ancestor::tei:opener) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)]" mode="add-numbering">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="n">
				<xsl:number count="tei:lg[(not(ancestor::tei:text[@type]) or ancestor::tei:text[@type ne 'poem']) and not(ancestor::tei:opener) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)] | tei:p[(not(ancestor::tei:text[@type]) or ancestor::tei:text[@type ne 'poem']) and not(ancestor::tei:opener) and not(ancestor::tei:closer) and not(ancestor::tei:table) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)]" level="any" from="/tei:TEI/tei:text/tei:body"/>
			</xsl:attribute>
			<xsl:apply-templates mode="add-numbering"/>
		</xsl:copy>
	</xsl:template>


	<!-- * Paragraph numbering (only in prose, together with
	     * line group numbering):
	     * <p> that are descendants of <opener>, <closer>, <table>,
	     * <note> or <floatingText> are not numbered. * -->
	<xsl:template match="tei:p[ancestor::tei:text and (not(ancestor::tei:text[@type]) or ancestor::tei:text[@type ne 'poem']) and not(ancestor::tei:opener) and not(ancestor::tei:closer) and not(ancestor::tei:table) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)]" mode="add-numbering">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="n">
				<xsl:number count="tei:lg[(not(ancestor::tei:text[@type]) or ancestor::tei:text[@type ne 'poem']) and not(ancestor::tei:opener) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)] | tei:p[(not(ancestor::tei:text[@type]) or ancestor::tei:text[@type ne 'poem']) and not(ancestor::tei:opener) and not(ancestor::tei:closer) and not(ancestor::tei:table) and not(ancestor::tei:note) and not(ancestor::tei:floatingText)]" level="any" from="/tei:TEI/tei:text/tei:body"/>
			</xsl:attribute>
			<xsl:apply-templates mode="add-numbering"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>