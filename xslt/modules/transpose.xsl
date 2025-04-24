<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: transpose.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-02-17
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-02-17)
	*
	*    Description:
	*        This XSLT module is designed to reorder transposed elements
	*        within TEI-encoded XML documents. It processes elements with
	*        @xml:id and reorders them based on a predefined mapping
	*        derived from <ptr @target> elements in <listTranspose>. By
	*        utilizing an indexed mapping mechanism, it ensures that
	*        transposed elements appear in the correct order, while
	*        preserving their attributes and structural integrity.
	*
	*    Key Features:
	*        - Operates in the `transpose` mode with
	*          `on-no-match="shallow-copy"`, ensuring that unmatched
	*          nodes are copied to the output without modification.
	*        - Extracts ordering information from <ptr @target> elements
	*          within <transpose> in <listTranspose>, see
	*          https://www.tei-c.org/release/doc/tei-p5-doc/en/html/PH.html#transpo
	*        - Any element marked with an @xml:id value that corresponds
	*          to a <ptr> element with matching @target (prefixed with
	*          '#') can be transposed using this stylesheet. The
	*          transposed elements do not need to be siblings.
	*        - Preserves all attributes and child nodes of the processed
	*          elements.
	*        - The <listTranspose> element and it's children are not
	*          included in the output, as they are no longer needed after
	*          transpositions have been executed.
	*
	*    Usage:
	*        Import or include this module in a main XSLT stylesheet and
	*        apply templates using the `transpose` mode to execute
	*        the transformation.
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS ****************************************** -->

	<xsl:mode name="transpose" on-no-match="shallow-copy"/>



	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * 1. For each <tei:transpose> group, we build a map whose keys are
	     * the target IDs (extracted from the <tei:ptr> elements) and whose
	     * values are the document-order positions of the elements with
	     * matching @xml:id values. This map tells us, for each transpose
	     * group, what the “original” document positions of the targets
	     * are. The variable holds a sequence of maps, one map for each
	     * transpose group. * -->
	<xsl:variable name="orig-order-maps-seq" as="map(xs:string, xs:integer)*">
		<xsl:for-each select="//tei:listTranspose/tei:transpose[tei:ptr[substring-after(@target, '#') = //tei:*[@xml:id]/@xml:id]]
			">
			<xsl:variable name="transpose-group" select="."/>
			<xsl:map>
				<xsl:for-each select="//tei:*[@xml:id = $transpose-group/tei:ptr/substring-after(@target, '#')]">
					<xsl:map-entry key="string(@xml:id)" select="position()"/>
				</xsl:for-each>
			</xsl:map>
		</xsl:for-each>
	</xsl:variable>


	<!-- * 2. For each <tei:transpose> group, we build a map where the keys
	     * are again the target IDs (from <tei:ptr>) but the values are the
	     * positions (i.e. the order in which the <ptr> elements appear
	     * within the <transpose> group). This map tells us what the
	     * “transposed” order is. The variable holds a sequence of maps,
	     * one map for each transpose group. * -->
	<xsl:variable name="transposed-order-maps-seq" as="map(xs:string, xs:integer)*">
		<xsl:for-each select="//tei:listTranspose/tei:transpose">
			<xsl:map>
				<xsl:for-each select="tei:ptr">
					<xsl:map-entry key="substring-after(@target, '#')" select="position()"/>
				</xsl:for-each>
			</xsl:map>
		</xsl:for-each>
	</xsl:variable>


	<!-- * 3. We then iterate over these two sequences of maps. For each
	     * group where the keys match, we compare the positions: for each
	     * key in the transposed map, we search for a key in the original
	     * map that has the same numerical value (i.e. the same position)
	     * and then create a mapping from the original key to the
	     * transposed key. Essentially, we’re “pairing” the original order
	     * with the transposed order. The variable holds a sequence of
	     * maps, one map for each transpose group. * -->
	<xsl:variable name="replacement-maps-seq" as="map(xs:string, xs:string)*">
		<xsl:for-each select="$transposed-order-maps-seq">
			<xsl:variable name="transposed-map" select="."/>
			<xsl:for-each select="$orig-order-maps-seq">
				<xsl:variable name="orig-map" select="."/>
				<xsl:if test="map:keys($transposed-map) = map:keys($orig-map)">
					<xsl:map>
						<xsl:for-each select="map:keys($transposed-map)">
							<xsl:variable name="transposed-map-key" select="."/>
							<xsl:for-each select="map:keys($orig-map)">
								<xsl:variable name="orig-map-key" select="."/>
								<xsl:if test="$transposed-map($transposed-map-key) eq $orig-map($orig-map-key)">
									<xsl:map-entry key="$orig-map-key" select="$transposed-map-key"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:map>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>


	<!-- * 4. Finally, we combine the sequence of individual replacement
	     * maps into one overall replacement map. This map has as keys the
	     * @xml:id values that should be replaced, and as values the
	     * corresponding replacement IDs. The variable holds a map. * -->
	<xsl:variable name="replacement-map" as="map(xs:string, xs:string)">
		<xsl:map>
			<xsl:for-each select="$replacement-maps-seq">
				<xsl:variable name="replacement-map" select="."/>
				<xsl:for-each select="map:keys(.)">
					<xsl:map-entry key="." select="map:get($replacement-map, .)"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:map>
	</xsl:variable>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Match any element with a @xml:id value equal to a @target value
	     * in a <ptr> element in a <transpose> group. If the @xml:id value
	     * is in the replacement map, copy the node corresponding to the
	     * replacement ID, otherwise copy the node as it is. * -->
	<xsl:template match="tei:*[@xml:id][@xml:id = //tei:listTranspose/tei:transpose/tei:ptr/substring-after(@target, '#')]" mode="transpose">
		<xsl:variable name="replacement-id" select="map:get($replacement-map, @xml:id)"/>
		<xsl:choose>
			<xsl:when test="$replacement-id">
				<!-- * Copy the replacement node. * -->
				<xsl:copy-of select="//tei:*[@xml:id eq $replacement-id]"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- * Non-transposed nodes are processed normally. * -->
				<xsl:copy>
					<xsl:apply-templates select="@* | node()" mode="transpose"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- * Remove the <listTranspose> element and it's children from the
	     * output, as they're not needed once the transpositions have been
	     * executed. * -->
	<xsl:template match="tei:listTranspose" mode="transpose"/>

</xsl:stylesheet>