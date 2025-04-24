<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: strip-xml-space.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-02-22
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-02-22)
	*
	*    Description:
	*        This XSLT module removes the `@xml:space` attribute from
	*        <body> elements, while preserving all other attributes. All
	*        other nodes and attributes are preserved in the output.
	*
	*    Key Features:
	*        - Operates in the `strip-xml-space` mode with
	*          `on-no-match="shallow-copy"`, ensuring that unmatched nodes
	*          are copied to the output without modification.
	*
	*    Usage:
	*        Import or include this module in a main XSLT stylesheet and
	*        apply templates using the `strip-xml-space` mode to execute
	*        the transformation.
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS ****************************************** -->

	<xsl:mode name="strip-xml-space" on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Strip the @xml:space attribute. * -->
	<xsl:template match="@xml:space" mode="strip-xml-space"/>


	<!-- * Strip the @xml:space attribute from the <body> element, while
	     * preserving all other attributes and child nodes. *	-->
	<xsl:template match="tei:body" mode="strip-xml-space">
		<xsl:copy>
			<!-- * Copy all attributes except @xml:space. * -->
			<xsl:apply-templates select="@*" mode="strip-xml-space"/>
			<!-- * Process (copy) child nodes. * -->
			<xsl:apply-templates select="node()" mode="strip-xml-space"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>