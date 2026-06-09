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
	*    XSLT stylesheet: est.xsl
	*
	*    Version: 3.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-03-07
	*    Licence: CC BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v3.0.0 (2026-06-09)
	*             - Update tei:app template based on changed spec.
	*        v2.2.0 (2026-04-21)
	*             - Don't output empty lines for lines with only deleted
	*               content.
	*             - Render <note> without @place and not decendant of <p>
	*               as <p>.
	*        v2.1.0 (2025-12-04)
	*             - Support <head type="part"> as part of hgroup.
	*        v2.0.2 (2025-11-19)
	*             - Support "hangingIndent" @rend value in <list>.
	*        v2.0.1 (2025-10-14)
	*             - Enable output indentation.
	*        v2.0.0 (2025-09-11)
	*             - Add form-shift classname to tei:head, tei:p, tei:note
	*               and tei:seg if applicable.
	*             - Remove processing of @rend in tei:seg.
	*        v1.1.1 (2025-04-24)
	*             - Move match templates common to est.xsl, ms_changes.xsl
	*               and ms_normalized.xsl to shared-match-templates.xsl,
	*               which is imported.
	*        v1.1.0 (2025-04-24)
	*             - Use named template for processing document headings.
	*             - Modify template for tei:del to handle cases where
	*               ancestor is tei:restore.
	*             - Fix template for tei:opener.
	*             - Fix last line XPath in tei:l template.
	*             - Remove superfluous CSS class name in tei:anchor
	*               template.
	*             - Add debug input parameter for running transformation
	*               in debug ”mode”.
	*        v1.0.1 (2025-03-12)
	*             - Fix heading level offset.
	*        v1.0.0 (2025-03-07)
	*
	*    Description:
	*        This XSLT document processes a TEI-encoded reading-text XML
	*        document and transforms it to HTML5 for inclusion on the
	*        project website. The input document should be a preprocessed
	*        reading-text ("est") XML document, generated with the SLS
	*        Digital Edition API publisher script.
	*
	*        The generated HTML5 output is not a complete HTML document,
	*        but an HTML fragment, which can be incorporated in an HTML
	*        page.
	*
	*    Input parameters:
	*        - bookId (xs:string?, default: empty): The ID of the text
	*          collection that the document is included in. Can be used
	*          to process texts of different collections differently.
	*          Currently not used.
	*        - sectionId (xs:string?, default: empty): The ID of the
	*          section of the input document which is to be processed. If
	*          no sectionId is provided, the whole document is processed.
	*        - debug (xs:boolean?, default: false): Run transformation in
	*          debug ”mode” with additional output for easier debugging.
	*
	******************************************************************* -->


	<!-- * SERIALIZATION OPTIONS ************************************** -->

	<xsl:output method="html" html-version="5.0" encoding="UTF-8"
	            include-content-type="no" indent="yes"/>

	<xsl:strip-space elements="tei:TEI tei:address tei:argument tei:body
	                           tei:cit tei:closer tei:div tei:epigraph
	                           tei:lg tei:list tei:opener tei:postscript
	                           tei:row tei:table tei:teiHeader tei:text"/>



	<!-- * IMPORTS **************************************************** -->

	<xsl:import href="required-global-variables.xsl"/>
	<xsl:import href="shared-functions.xsl"/>
	<xsl:import href="shared-named-templates.xsl"/>
	<xsl:import href="shared-match-templates.xsl"/>



	<!-- * PARAMETERS *****************************************************
	     * Declare input parameters. * -->

	<!-- * The bookId and sectionId parameters should not be used in the
	     * stylesheet, but rather the global variables derived from these,
	     * see below. * -->
	<xsl:param name="bookId" as="xs:string?" select="()"/>
	<xsl:param name="sectionId" as="xs:string?" select="()"/>

	<!-- * Parameter for enabling debug ”mode”. * -->
	<xsl:param name="debug" as="xs:boolean?" select="false()"/>



	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * Normalize $bookId to be either a non-empty string or the empty
	     * sequence, and store in a global variable called
	     * $collection-id. * -->
	<xsl:variable name="collection-id" as="xs:string?"
	              select="if (string-length($bookId) gt 0)
	                          then $bookId else ()"/>

	<!-- * Normalize $sectionId to be either a non-empty string or the
	     * empty sequence, and store in a global variable called
	     * $section-id. * -->
	<xsl:variable name="section-id" as="xs:string?"
	              select="if (string-length($sectionId) gt 0)
	                          then $sectionId else ()"/>

	<!-- * An integer offset to add to the heading levels in the output.
	     * If set to 0, the top-most heading will be a <h1>, if set to 1,
	     * the top-most heading will be a <h2>, etc. Because the output
	     * HTML is embedded in a webpage with pre-existing headings, the
	     * heading levels need to be offset. * -->
	<xsl:variable name="heading-level-offset" as="xs:integer" static="yes"
	              select="2"/>



	<!-- * TEMPLATES ******************************************************
	     * Reminder on XSLT default behaviour for unmatched nodes:
	     * element nodes are unwrapped and children processed (same as
	     * apply-templates applied to them); the content (text) of text
	     * nodes is outputted. * -->

	<!-- * Note: many match templates are imported from
	     * `shared-match-templates.xsl`. * -->

	<xsl:template match="tei:head[not(parent::tei:figure)
	                              and not(parent::tei:table)
	                              and not(@type eq 'subtitle')]">
		<xsl:choose>
			<xsl:when test="@type eq 'part'
			                and current-grouping-key() eq 'hgroup'
			                and count(current-group()) gt 1
			                and preceding-sibling::tei:head[@type ne 'subtitle']">
				<p>
					<xsl:call-template name="set-class-attr">
						<xsl:with-param name="class-names"
							select="('part-title',
							         slsFn:get-form-shift-classname(.))"/>
					</xsl:call-template>
					<xsl:apply-templates/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="document-heading"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:head[@type eq 'subtitle']">
		<p role="doc-subtitle">
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
					select="(slsFn:get-form-shift-classname(.))"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:head[parent::tei:table]">
		<caption>
			<xsl:apply-templates/>
		</caption>
	</xsl:template>


	<xsl:template match="tei:head[parent::tei:figure]">
		<figcaption>
			<xsl:apply-templates/>
		</figcaption>
	</xsl:template>


	<xsl:template match="tei:ab[parent::tei:epigraph] |
	                     tei:address |
	                     tei:bibl[ancestor::tei:opener] |
	                     tei:byline |
	                     tei:dateline |
	                     tei:p[parent::tei:argument] |
	                     tei:salute |
	                     tei:signed">
		<p>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (parent::tei:argument)
				                             then 'argument'
				                         else if (not(local-name() eq 'p'))
				                             then local-name() else (),
				                         if (ancestor::tei:epigraph)
				                             then 'epigraph' else (),
				                         @rend)"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:addrLine">
		<xsl:apply-templates/>
		<xsl:if test="not(. is (ancestor::tei:address//tei:addrLine[last()]))">
			<br/><xsl:text>{if ($debug) then $NL else ''}</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:p">
		<p>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names" select="(@rend,
				                                            slsFn:get-form-shift-classname(.))"/>
			</xsl:call-template>
			<xsl:call-template name="add-paragraph-number"/>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:quote">
		<xsl:variable name="element-name" as="xs:string"
		              select="if (@type eq 'block' and not(ancestor::tei:opener))
		                          then 'blockquote'
		                      else 'p'"/>

		<xsl:element name="{$element-name}">
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if ($element-name eq 'p')
				                             then 'quote' else (),
				                         if (ancestor::tei:epigraph)
				                             then 'epigraph' else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:lg">
		<p>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('lg', @type)"/>
			</xsl:call-template>
			<xsl:call-template name="add-paragraph-number"/>
			<xsl:text>{if ($debug) then $NL else ''}</xsl:text>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:l">
		<xsl:variable name="lg-type" as="xs:string?"
		              select="parent::tei:lg/@type"/>
		<xsl:variable name="line-label" as="xs:string?"
		              select="if ($lg-type eq 'labelledLinesBefore'
				                  or $lg-type eq 'labelledLinesAfter')
				                  then $lg-type else ()"/>

		<span>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('l', @rend,
				                         if (@part)
				                             then 'part' || @part else ())"/>
			</xsl:call-template>
			<xsl:call-template name="add-line-number"/>
			<xsl:choose>
				<xsl:when test="$line-label and tei:label">
					<xsl:choose>
						<xsl:when test="tei:label is node()[1]">
							<span class="lLabel">
								<xsl:apply-templates select="tei:label"/>
							</span>
							<span>
								<xsl:apply-templates select="node() except tei:label"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<span>
								<xsl:apply-templates select="node() except tei:label"/>
							</span>
							<span class="lLabel">
								<xsl:apply-templates select="tei:label"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		
		<xsl:variable name="last-line" as="element(tei:l)?"
		              select="((ancestor::tei:lg[1]//tei:l)
		                      except (ancestor::tei:lg[1]//tei:lg//tei:l))[last()]"/>
		<xsl:if test="not(. is $last-line)">
			<br/><xsl:text>{if ($debug) then $NL else ''}</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:label">
		<xsl:choose>
			<xsl:when test="parent::tei:lg[@type eq 'labelledAbove'
			                               or @type eq 'labelledMargin']
			                and @place">
				<span class="label{substring(@place, 1, 1) => upper-case()}{substring(@place, 2)}">
					<xsl:apply-templates/>
				</span><xsl:text>{if ($debug) then $NL else ''}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:list">
	<!-- * @rend values 'indent', 'disc' and 'dash' and missing @rend
	     * results in an unordered list, otherwise an ordered list. * -->
		<xsl:element name="{if (not(@rend) or @rend eq 'indent'
			                    or @rend eq 'hangingIndent'
		                        or @rend eq 'disc' or @rend eq 'dash')
		                        then 'ul'
		                    else 'ol'}">
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (@rend)
				                             then @rend
				                         else 'plain',
				                         if (parent::tei:argument)
				                             then 'argument' else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="tei:item">
		<li>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:apply-templates/>
		</li>
	</xsl:template>


	<xsl:template match="tei:table">
	<!-- * Tables are wrapped in a <div> so large tables can be
		   scrolled horizontally. -->
		<div class="table-wrapper">
			<table>
				<xsl:call-template name="set-attr-from-xml-id"/>
				<xsl:call-template name="set-attr-from-xml-lang"/>
				<xsl:call-template name="set-class-attr-from-rend"/>

				<!-- * Group the rows so the first child rows with
					 * @role="label" are wrapped in <thead> and the
					 * subsequent rows are wrapped in <tbody>. * -->
				<xsl:for-each-group select="node()"
					group-adjacent="if (self::tei:row[@role eq 'label']
					                    and (not(preceding-sibling::*)
					                         or preceding-sibling::tei:row[1][@role eq 'label']))
				                        then 'thead'
				                    else 'tbody'">
					<xsl:element name="{current-grouping-key()}">
						<xsl:for-each select="current-group()">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each-group>
			</table>
		</div>
	</xsl:template>


	<xsl:template match="tei:cell">
		<xsl:variable name="is-header" as="xs:boolean"
		              select="if (parent::tei:row[@role eq 'label']
		                          or @role eq 'label')
		                          then true()
		                      else false()"/>
		<xsl:variable name="colspan" as="xs:integer?"
		              select="let $parent-cols := parent::tei:row/@cols,
		                          $cols-str := if ($parent-cols)
		                                           then $parent-cols
		                                       else @cols,
		                          $cols-int := if ($cols-str castable as xs:integer)
		                                           then xs:integer($cols-str) else ()
		                      return if ($cols-int gt 1)
		                                 then $cols-int else ()"/>
		<xsl:variable name="rowspan" as="xs:integer?"
		              select="let $rows-int := if (@rows castable as xs:integer)
		                                           then xs:integer(@rows) else ()
		                      return if ($rows-int gt 1)
		                                 then $rows-int else ()"/>

		<xsl:element name="{if ($is-header) then 'th' else 'td'}">
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="distinct-values((@rend,
				                                         parent::tei:row/@rend))"/>
			</xsl:call-template>
			<xsl:where-populated>
				<xsl:attribute name="colspan" select="$colspan"/>
			</xsl:where-populated>
			<xsl:where-populated>
				<xsl:attribute name="rowspan" select="$rowspan"/>
			</xsl:where-populated>
			<xsl:where-populated>
				<xsl:attribute name="scope"
					select="if ($is-header and $colspan)
					           then 'colgroup'
					       else if ($is-header and $rowspan)
					           then 'rowgroup'
					       else if (@role eq 'label'
					                and not(preceding-sibling::*)
					                and not(following-sibling::tei:cell[@role eq 'label']))
					           then 'row'
					       else if ($is-header)
					           then 'col' else ()"/>
			</xsl:where-populated>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:lb">
		<xsl:choose>
			<!-- * To avoid blank lines due to lines with only deleted
			     * content, don't output anything if:
			     * - the following siblings contain at least one tei:del
			     *   and only comments, and whitespace-only text nodes
			     * - the following siblings before the next sibling <lb/>
			     *   contain at least one tei:del and only comments, and
			     *   whitespace-only text nodes * -->
			<xsl:when test="let $allowed := function($n as node()) as xs:boolean {
	                            $n/self::comment()
	                            or $n/self::tei:del
	                            or ($n instance of text() and normalize-space($n) eq '')
	                        },
	                        $lb := following-sibling::tei:lb[1],
	                        $range := if (exists($lb))
	                                  then following-sibling::node()[. &lt;&lt; $lb]
	                                  else following-sibling::node()
	                        return
	                            exists($range[self::tei:del])
	                            and
	                            (every $n in $range satisfies $allowed($n))
	        "/>
			<xsl:otherwise>
				<br/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:note">
		<xsl:if test="@place and @xml:id">
			<span tabindex="0" role="doc-noteref">
				<xsl:call-template name="set-attr-from-xml-id"/>
				<xsl:call-template name="set-attr-from-xml-lang"/>
				<xsl:call-template name="set-class-attr">
					<xsl:with-param name="class-names"
						select="('footnoteindicator tooltiptrigger ttFoot',
						         @xml:id)"/>
				</xsl:call-template>
				<xsl:text>{@n}</xsl:text>
			</span>
			<span class="tooltip ttFoot" hidden="">
				<span class="tei ttFixed">
					<xsl:call-template name="set-attr-from-xml-id"/>
					<xsl:call-template name="apply-templates-with-optional-form-shift-wrapper"/>
				</span>
			</span>
		</xsl:if>
		<xsl:if test="not(@place) and not(ancestor::tei:p)">
			<p>
				<xsl:call-template name="set-attr-from-xml-lang"/>
				<xsl:call-template name="set-class-attr">
					<xsl:with-param name="class-names"
						select="('note',
						         if (parent::tei:opener)
						             then 'left'
						         else ())"/>
				</xsl:call-template>
				<xsl:apply-templates/>
			</p>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:anchor">
		<xsl:choose>
			<xsl:when test="starts-with(@xml:id, 'start')">
				<span class="anchor_lemma" data-id="{@xml:id}">
					<img src="{$icons-base-path}/ms_arrow_right.svg"
					     alt="lemma start" loading="lazy"/>
				</span>
			</xsl:when>
			<xsl:when test="starts-with(@xml:id, 'end')">
				<!-- Is the id really needed as a class name? Check frontend. -->
				<img src="{$icons-base-path}/asterisk.svg" alt="kommentar"
				     class="comment commentScrollTarget tooltiptrigger ttComment en{substring(@xml:id, 4)}"
				     loading="lazy" tabindex="0">
					<xsl:call-template name="set-attr-from-xml-id"/>
				</img>
			</xsl:when>
			<xsl:when test="@type eq 'xref'">
				<!-- Another test option here would be to see if there is 
				not an <addSpan> or <delSpan> with matching @spanTo -->
				<!-- Anchors were previously <a>, check if frontend
				supports this: -->
				<span class="anchor" aria-hidden="true">
					<xsl:call-template name="set-attr-from-xml-id"/>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:unclear">
	<!-- * If @reason is 'overstrike' or 'overwritten' the content is
	     * stripped. * -->
		<xsl:if test="not(@reason eq 'overstrike')
		              and not(@reason eq 'overwritten')">
			<xsl:variable name="reason" as="xs:string"
				select="if (not(@reason) and parent::tei:del[parent::tei:subst])
			                then 'overwritten'
			            else if (not(@reason))
			                then 'writing'
			            else @reason"/>
			<span class="unclear tooltiptrigger ttMs">
				<xsl:apply-templates/>
			</span>
			<span class="tooltip" hidden="">
				<xsl:text>svårtytt, orsak: {slsFn:get-reason-text($reason)}</xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:gap | tei:space">
	<!-- * If @reason is 'overstrike', 'overwritten' or 'erased' the
	     * content is stripped. * -->
		<xsl:if test="not(@reason eq 'overstrike')
		              and not(@reason eq 'overwritten')
		              and not(@reason eq 'erased')">
			<xsl:call-template name="add-gap-space-content"/>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:del">
		<xsl:if test="(ancestor::tei:restore and parent::tei:subst)
			          or parent::tei:restore">
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:metamark"/>


	<xsl:template match="tei:seg">
		<xsl:choose>
			<xsl:when test="@type eq 'alt'">
				<xsl:apply-templates select="tei:add[@type eq 'choice']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="apply-templates-with-optional-form-shift-wrapper"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:supplied">
		<span class="corr_red choice tooltiptrigger ttChanges">
			<xsl:apply-templates/>
		</span>
		<span class="tooltip ttChanges" hidden="">
			<xsl:text>{
				if (@reason)
				    then 'oläsligt, orsak: ' || slsFn:get-reason-text(@reason)
				else if (@source)
				    then 'tillagt av utgivaren (källa för ändring: ' || @source || ')'
				else 'tillagt av utgivaren'
			}</xsl:text>
		</span>
	</xsl:template>


	<xsl:template match="tei:choice">
		<span>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('tooltiptrigger',
				                         if (tei:abbr)
				                             then 'abbr ttAbbreviations'
				                         else if (tei:orig)
				                             then 'choice ttChanges'
				                         else 'choice')"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</span>
		<xsl:choose>
			<xsl:when test="tei:expan">
				<span class="tooltip ttAbbreviations" hidden="">
					<xsl:apply-templates select="tei:expan/node()"/>
				</span>
			</xsl:when>
			<xsl:when test="tei:orig">
				<span class="tooltip ttChanges" hidden="">
					<xsl:text>original: </xsl:text>
					<xsl:apply-templates select="tei:orig/node()"/>
					<xsl:if test="tei:reg[@source]">
						<xsl:text> (källa för ändring: {tei:reg/@source})</xsl:text>
					</xsl:if>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:abbr">
		<span class="abbr">
			<xsl:apply-templates/>
		</span>
	</xsl:template>


	<xsl:template match="tei:reg">
		<xsl:choose>
			<xsl:when test="parent::tei:choice">
				<span class="corr{if (@type eq 'empty')
				                      then ' corr_hide' else ''}">
					<xsl:choose>
						<xsl:when test="@type eq 'empty'">
							<xsl:sequence select="$empty-icon-image"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<span class="reg{if (@type eq 'empty') then '_hide' else ''} tooltiptrigger ttNormalisations">
					<xsl:choose>
						<xsl:when test="@type eq 'empty'">
							<xsl:sequence select="$empty-icon-image"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<span class="tooltip ttNormalisations" hidden="">
					<xsl:text>konsekvensändrat/normaliserat</xsl:text>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:app">
		<xsl:variable name="lem-wit" as="element(tei:witness)*"
		              select="slsFn:get-witnesses(tei:lem)"/>
		<span class="choice tooltiptrigger ttChanges">
			<xsl:apply-templates select="tei:lem"/>
		</span>
		<span class="tooltip ttChanges" hidden="">
			<xsl:text>tryckvarians{if (count($lem-wit) gt 1)
				                       then ', källor: '
				                   else if (count($lem-wit) gt 0)
				                       then ', källa: '
				                   else ''}</xsl:text>
			<xsl:for-each select="$lem-wit">
				<xsl:apply-templates select="if (exists(@n))
					                             then @n
					                         else ."/>
				<xsl:if test="count($lem-wit) gt 1 and position() ne last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>;</xsl:text>
			<br/>
			<xsl:text>lydelse i övriga textvittnen:</xsl:text>
			<xsl:for-each select="tei:rdg">
				<br/>
				<xsl:apply-templates select="node()"/>
				<xsl:variable name="rdg-wit" as="element(tei:witness)*"
		                      select="slsFn:get-witnesses(.)"/>
				<xsl:if test="exists($rdg-wit)">
					<xsl:text> (</xsl:text>
					<xsl:for-each select="$rdg-wit">
						<xsl:apply-templates select="if (exists(@n))
							                             then @n
							                         else ."/>
						<xsl:if test="count($rdg-wit) gt 1 and position() ne last()">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</span>
	</xsl:template>


	<xsl:template match="tei:lem">
		<span class="corr{if (@type eq 'empty') then ' corr_hide' else ''}">
			<xsl:choose>
				<xsl:when test="@type eq 'empty'">
					<xsl:sequence select="$empty-icon-image"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>


	<xsl:template match="tei:expan | tei:orig | tei:rdg"/>


	<xsl:template match="tei:corr">
		<span class="corr{if (@type eq 'empty') then '_hide' else '_red'} tooltiptrigger ttChanges">
			<xsl:choose>
				<xsl:when test="@type eq 'empty'">
					<xsl:sequence select="$empty-icon-image"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		<span class="tooltip ttChanges" hidden="">
			<xsl:text>{
				if (@source) then @source else 'rättelse i originalet'
			}</xsl:text>
		</span>
	</xsl:template>

</xsl:stylesheet>