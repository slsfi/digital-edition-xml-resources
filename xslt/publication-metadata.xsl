<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:array="http://www.w3.org/2005/xpath-functions/array"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: publication-metadata.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2026-05-21
	*    Licence: CC-BY 4.0 (Attribution 4.0 International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2026-05-21)
	*
	*    Description:
	*        This XSLT document creates publication-level metadata as JSON.
	*        It combines metadata supplied by the calling application with
	*        metadata read from referenced TEI XML documents, normalises selected
	*        values, and emits a compact metadata object for downstream use.
	*
	*    Usage:
	*        Set the db-json input parameter on the XSLT processor and run the
	*        stylesheet with its initial template. No primary source document is
	*        required; XML documents are loaded from URI values in the input
	*        metadata when available.
	*
	*    Input parameters:
	*        - db-json (xs:string?, required): A JSON object serialised as a
	*          string. The object is parsed with parse-json() and is expected to
	*          contain publication metadata from the database.
	*
	*          Expected top-level shape:
	*
	*              {
	*                  "metadata_language": "...",
	*                  "publication_id": "...",
	*                  "publication_title": "...",
	*                  "publication_date": "...",
	*                  "publication_genre": "...",
	*                  "publication_language": "...",
	*                  "publication_filepath": "...",
	*                  "publication_filepath_uri": "...",
	*                  "comment_filepath": "...",
	*                  "comment_filepath_uri": "...",
	*                  "collection_id": "...",
	*                  "collection_title": "...",
	*                  "facsimiles": [ ... ],
	*                  "manuscripts": [ ... ],
	*                  "variants": [ ... ]
	*              }
	*
	*          The facsimiles array contains objects with facsimile metadata,
	*          including id, facs_coll_id, publication_manuscript_id,
	*          publication_variant_id, title, section_id, priority, page_nr,
	*          number_of_images, description and external_url.
	*
	*          The manuscripts array contains objects with manuscript metadata,
	*          including id, title, original_filename, original_filename_uri,
	*          section_id, sort_order and language.
	*
	*          The variants array contains objects with variant metadata,
	*          including id, title, original_filename, original_filename_uri,
	*          section_id, sort_order and type.
	*
	*    Output:
	*        A JSON object containing normalised publication metadata.
	*
	******************************************************************* -->


	<!-- * SERIALIZATION OPTIONS ************************************** -->

	<xsl:output method="json" encoding="UTF-8" indent="yes"
	            json-node-output-method="text"/>



	<!-- * IMPORTS **************************************************** -->

	<xsl:import href="shared-date-functions.xsl"/>
	<xsl:import href="shared-language-functions.xsl"/>
	<xsl:import href="shared-tei-to-html-string-functions.xsl"/>



	<!-- * PARAMETERS *****************************************************
	     * Declare input parameters. * -->

	<xsl:param name="db-json" as="xs:string?" select="()"/>



	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * The JSON text metadata from the database parsed into a map. * -->
	<xsl:variable name="db-meta" as="map(*)" select="parse-json($db-json)"/>

	<!-- * Target language of the metadata, i.e. the language the output
		 * metadata should be in. * -->
	<xsl:variable name="meta-lang" as="xs:string"
		          select="slsFn:normalise-language($db-meta?metadata_language)"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Entry point: initial template. * -->
	<xsl:template name="xsl:initial-template">
		<!-- * Number of facsimiles. * -->
		<xsl:variable name="facs-count" as="xs:integer"
			          select="count($db-meta?facsimiles?*)"/>

		<!-- * Number of manuscripts. * -->
		<xsl:variable name="ms-count" as="xs:integer"
			          select="count($db-meta?manuscripts?*)"/>
		
		<!-- * Number of variants. * -->
		<xsl:variable name="var-count" as="xs:integer"
			          select="count($db-meta?variants?*)"/>

		<!-- * Boolean which is true if the publication has a publication_filepath,
			 * i.e. a reading text XML file. * -->
		<xsl:variable name="has-readingtext" as="xs:boolean"
		              select="boolean(normalize-space($db-meta?publication_filepath))"/>

		<!-- * Boolean which is true if the publication consists of only
			 * one manuscript, which is set as the reading text, or there
			 * is no reading text. * -->
		<xsl:variable name="single-ms-publication" as="xs:boolean"
		              select="let $first-ms-filepath := 
		                          if ($ms-count gt 0)
		                              then $db-meta?manuscripts?1?original_filename_uri
		                          else ()
		                      return
		                          $ms-count eq 1 and
		                          exists($first-ms-filepath) and
		                          (
		                           not($has-readingtext)
		                           or
		                           $db-meta?publication_filepath_uri eq $first-ms-filepath
		                          )"/>

		<xsl:variable name="main-doc" as="document-node()?"
		              select="if ($single-ms-publication)
		                          then slsFn:doc-if-available($db-meta?manuscripts?1?original_filename_uri)
		                      else (
		                          let $publication-file := slsFn:doc-if-available($db-meta?publication_filepath_uri)
		                          return
		                              if (exists($publication-file))
		                                  then $publication-file
		                              else ()
		                      )"/>

		<xsl:variable name="publication-title" as="xs:string"
		              select="let $norm-publ-title := normalize-space($db-meta?publication_title)
		                      return
		                          if (boolean($norm-publ-title))
						              then $norm-publ-title
						          else if ($single-ms-publication)
						              then normalize-space($db-meta?manuscripts?1?title)
						          else if ($meta-lang eq 'en')
						              then 'unknown title'
						          else if ($meta-lang eq 'fi')
						              then 'tuntematon nimike'
						          else 'okänd titel'"/>

		<xsl:variable name="publication-language" as="xs:string?"
		              select="let $lang-code:= slsFn:normalise-language(
		                                           ($db-meta?publication_language,
		                                            $main-doc/tei:TEI/tei:text/@xml:lang)[1]
		                                       )
		                      return slsFn:language-name($lang-code, $meta-lang)"/>

		<xsl:variable name="keywords-elem" as="element(tei:keywords)?"
		              select="$main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
		                      /tei:textClass/tei:keywords"/>

		<xsl:variable name="publication-genre" as="xs:string?"
		              select="let $genre := ($keywords-elem/tei:term[@type eq 'genre'][@xml:lang eq $meta-lang],
		                                     $keywords-elem/tei:term[@type eq 'genre'],
		                                     $db-meta?publication_genre)[1]
		                      return
		                          if (boolean(normalize-space($genre)))
		                              then string($genre) => normalize-space() => lower-case()
		                          else ()"/>

		<xsl:variable name="keywords" as="xs:string?"
		              select="let $lang-terms := $keywords-elem/tei:term[not(@type eq 'genre')][@xml:lang eq $meta-lang],
		                          $terms := if (exists($lang-terms))
		                                        then $lang-terms
		                                    else $keywords-elem/tei:term[not(@type eq 'genre')]
		                      return
		                          if (exists($terms))
		                              then $terms ! normalize-space(.)
		                                   ! lower-case(.)
		                                   => sort('http://www.w3.org/2013/collation/UCA?lang=sv')
		                                   => string-join(', ')
		                          else ()"/>

		<xsl:variable name="sender" as="array(xs:string)"
		              select="array {
			                      for $s in $main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
			                          /tei:correspDesc/tei:correspAction[@type eq 'sent']
			                          //tei:persName
			                      return normalize-space(string($s))
			                  }"/>

		<xsl:variable name="receiver" as="array(xs:string)"
		              select="array {
			                      for $r in $main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
			                          /tei:correspDesc/tei:correspAction[@type eq 'received']
			                          //tei:persName
			                      return normalize-space(string($r))
			                  }"/>

		<xsl:map>
			<xsl:map-entry key="'id'"
				           select="$db-meta?publication_id"/>

			<xsl:map-entry key="'publication_title'"
				           select="$publication-title"/>

			<xsl:if test="exists($publication-language)">
				<xsl:map-entry key="'publication_language'"
				               select="$publication-language"/>
			</xsl:if>

			<xsl:if test="$publication-genre">
				<xsl:map-entry key="'publication_genre'"
				               select="$publication-genre"/>
			</xsl:if>

			<xsl:map-entry key="'collection_id'"
				           select="$db-meta?collection_id"/>

			<xsl:map-entry key="'collection_title'"
				           select="normalize-space($db-meta?collection_title)"/>

			<xsl:if test="exists($keywords)">
				<xsl:map-entry key="'keywords'"
			                   select="$keywords"/>
			</xsl:if>

			<xsl:sequence select="slsFn:tei-date-metadata-map(
			                          $main-doc,
			                          normalize-space($db-meta?publication_date),
			                          false()
			                      )"/>

			<xsl:if test="array:size($sender) eq 0">
				<xsl:sequence select="slsFn:tei-author-metadata-map($main-doc)"/>
			</xsl:if>

			<xsl:sequence select="slsFn:tei-source-metadata-map($main-doc)"/>

			<xsl:sequence select="slsFn:tei-physical-metadata-map($main-doc)"/>

			<xsl:sequence select="slsFn:tei-availability-metadata-map($main-doc)"/>
			
			<xsl:sequence select="slsFn:tei-responsibility-metadata-map($main-doc)"/>

			<xsl:if test="array:size($sender) gt 0">
				<xsl:map-entry key="'sender'"
				               select="$sender"/>
			</xsl:if>

			<xsl:if test="array:size($receiver) gt 0">
				<xsl:map-entry key="'recipient'"
				               select="$receiver"/>
			</xsl:if>

			<xsl:if test="$single-ms-publication or $ms-count eq 1">
				<xsl:map-entry key="'manuscript_id'"
				               select="$db-meta?manuscripts?1?id"/>
			</xsl:if>
			
			<xsl:if test="$facs-count gt 0">
				<xsl:map-entry key="'facsimiles'">
					<xsl:sequence select="
						array {
						    for $facs in $db-meta?facsimiles?*
						    return slsFn:facsimile-map($facs)
						}
					"/>
				</xsl:map-entry>
			</xsl:if>
			
			<!-- * Create manuscripts map if there are manuscripts and
			     * they do not comprise only a single manuscript which
			     * is also set as the reading text. * -->
			<xsl:if test="not($single-ms-publication) and $ms-count gt 0">
				<xsl:map-entry key="'manuscripts'">
					<xsl:sequence select="
						array {
						    for $ms in $db-meta?manuscripts?*
						    return slsFn:manuscript-map($ms)
						}
					"/>
				</xsl:map-entry>
			</xsl:if>
			
			<xsl:if test="$var-count gt 0">
				<xsl:map-entry key="'variants'">
					<xsl:sequence select="
						array {
						    for $var in $db-meta?variants?*
						    return slsFn:variant-map($var)
						}
					"/>
				</xsl:map-entry>
			</xsl:if>
		</xsl:map>


		<!-- * This is a map of all fields in the input metadata.
			 * It should only be used as reference. *

		<xsl:map>
			<xsl:map-entry key="'id'" select="$db-meta?publication_id"/>
			<xsl:map-entry key="'publication_title'" select="$db-meta?publication_title"/>
			<xsl:map-entry key="'publication_date'" select="$db-meta?publication_date"/>
			<xsl:map-entry key="'publication_genre'" select="$db-meta?publication_genre"/>
			<xsl:map-entry key="'publication_language'" select="$db-meta?publication_language"/>
			<xsl:map-entry key="'publication_filepath'" select="$db-meta?publication_filepath"/>
			<xsl:map-entry key="'publication_filepath_uri'" select="$db-meta?publication_filepath_uri"/>
			<xsl:map-entry key="'comment_filepath'" select="$db-meta?comment_filepath"/>
			<xsl:map-entry key="'comment_filepath_uri'" select="$db-meta?comment_filepath_uri"/>
			<xsl:map-entry key="'collection_id'" select="$db-meta?collection_id"/>
			<xsl:map-entry key="'collection_title'" select="$db-meta?collection_title"/>

			<xsl:map-entry key="'manuscripts'" select="
				array {
					for $ms in $db-meta?manuscripts?*
					return
						map {
							'id': $ms?id,
							'title': $ms?title,
							'original_filename': $ms?original_filename,
							'original_filename_uri': $ms?original_filename_uri,
							'section_id': $ms?section_id,
							'sort_order': $ms?sort_order,
							'language': $ms?language
						}
				}
			"/>

			<xsl:map-entry key="'variants'" select="
				array {
					for $var in $db-meta?variants?*
					return
						map {
							'id': $var?id,
							'title': $var?title,
							'original_filename': $var?original_filename,
							'original_filename_uri': $var?original_filename_uri,
							'section_id': $var?section_id,
							'sort_order': $var?sort_order,
							'type': $var?type
						}
				}
			"/>

			<xsl:map-entry key="'facsimiles'" select="
				array {
					for $fac in $db-meta?facsimiles?*
					return
						map {
							'id': $fac?id,
							'facs_coll_id': $fac?facs_coll_id,
							'publication_manuscript_id': $fac?publication_manuscript_id,
							'publication_variant_id': $fac?publication_variant_id,
							'title': $fac?title,
							'section_id': $fac?section_id,
							'priority': $fac?priority,
							'page_nr': $fac?page_nr,
							'number_of_images': $fac?number_of_images,
							'description': $fac?description,
							'external_url': $fac?external_url
						}
				}
			"/>
			</xsl:map>
			-->
	</xsl:template>



	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:doc-if-available" as="document-node()?">
		<!-- * Given a file path or a file URI, returns the document if it
			 * is available, otherwise returns an empty sequence. * -->
		<xsl:param name="uri" as="xs:string?"/>
	
		<xsl:sequence select="if ($uri and doc-available($uri))
		                          then doc($uri)
		                      else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:tei-author-metadata-map" as="map(*)?">
		<!-- * Constructs author metadata from a TEI document. * -->
		<xsl:param name="doc" as="document-node()?"/>

		<xsl:variable name="author" as="array(xs:string)"
		              select="array {
		                          for $a in $doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                              /tei:titleStmt/tei:author
		                          return normalize-space(string($a))
		                      }"/>

		<xsl:if test="array:size($author) gt 0">
			<xsl:map>
				<xsl:map-entry key="'author'"
				               select="$author"/>
			</xsl:map>
		</xsl:if>
	</xsl:function>


	<xsl:function name="slsFn:tei-date-metadata-map" as="map(*)?">
		<!-- * Constructs date metadata from a TEI document, falling back to
			 * the supplied date when the document has no usable date. * -->
		<xsl:param name="doc" as="document-node()?"/>
		<xsl:param name="fallback-date" as="xs:string?"/>
		<xsl:param name="orig-date-field" as="xs:boolean"/>

		<xsl:variable name="date-elem" as="element(*)"
		              select="let $source-desc := $doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                           /tei:sourceDesc,
		                          $history-orig-date := $source-desc/tei:msDesc/tei:history
		                           /tei:origin/tei:origDate
		                      return
		                          ($history-orig-date[@when or @notBefore or @notAfter or @from or @to],
		                           $source-desc//tei:origDate[@when or @notBefore or @notAfter or @from or @to],
		                           $source-desc//tei:date[@when or @notBefore or @notAfter or @from or @to][1],
		                           $doc/tei:TEI/tei:teiHeader/tei:profileDesc
		                               /tei:correspDesc/tei:correspAction[@type eq 'sent']
		                               /tei:date[@when or @notBefore or @notAfter or @from or @to][1])[1]"/>
		
		<xsl:variable name="date-content" as="xs:string?"
		              select="normalize-space($date-elem/string())"/>

		<xsl:variable name="publication-date" as="xs:string?"
		              select="if ($date-elem[@when])
		                          then (let $formatted-when := slsFn:format-w3c-date($date-elem/@when, $meta-lang)
		                                return
		                                    if ($formatted-when castable as xs:gYear and
		                                        boolean($date-content) and
		                                        starts-with($date-content, 'ca '))
		                                        then (slsFn:get-temporal-term('ca', $meta-lang), '~')[1] || substring($date-content, 3)
		                                    else $formatted-when
		                              )
		                      else if ($date-elem[@from or @to])
		                          then (let $from := slsFn:format-w3c-date($date-elem/@from, $meta-lang),
		                                    $to := slsFn:format-w3c-date($date-elem/@to, $meta-lang)
		                                return
		                                    if (exists($from) and exists($to))
		                                        then if ($from castable as xs:gYear and
		                                                 $to castable as xs:gYear and
		                                                 boolean($date-content) and
		                                                 starts-with($date-content, 'ca '))
		                                                 then (slsFn:get-temporal-term('ca', $meta-lang), '~')[1] || substring($date-content, 3)
		                                             else  $from || '–' || $to
		                                    else if (exists($from))
		                                        then (let $term := slsFn:get-temporal-term('from', $meta-lang)
		                                              return
		                                                  if (exists($term))
		                                                      then $term || ' ' || $from
		                                                  else $from || '–'
		                                             )
		                                    else (let $term := slsFn:get-temporal-term('to', $meta-lang)
		                                          return
		                                              if (exists($term))
		                                                  then $term || ' ' || $to
		                                              else '–' || $to
		                                         )
		                               )
		                      else if ($date-elem[@notBefore or @notAfter])
		                          then (let $not-before := slsFn:format-w3c-date($date-elem/@notBefore, $meta-lang),
		                                    $not-after := slsFn:format-w3c-date($date-elem/@notAfter, $meta-lang),
		                                    $not-before-term := (slsFn:get-temporal-term('notBefore', $meta-lang), 'not before')[1],
		                                    $not-after-term := (slsFn:get-temporal-term('notAfter', $meta-lang), 'not after')[1]
		                                return
		                                    if (exists($not-before) and exists($not-after))
		                                        then if ($not-before castable as xs:gYear and
		                                                 $not-after castable as xs:gYear and
		                                                 boolean($date-content) and
		                                                 starts-with($date-content, 'ca '))
		                                                 then (slsFn:get-temporal-term('ca', $meta-lang), '~')[1] || substring($date-content, 3)
		                                             else $not-before-term || ' ' || $not-before || ', ' || $not-after-term || ' ' || $not-after
		                                    else if (exists($not-before))
		                                        then $not-before-term || ' ' || $not-before
		                                    else $not-after-term || ' ' || $not-after
		                               )
		                      else slsFn:format-w3c-date(normalize-space($fallback-date), $meta-lang)"/>

		<xsl:if test="exists($publication-date)">
			<xsl:map>
				<xsl:map-entry key="if ($orig-date-field)
					                    then 'orig_date'
					                else 'publication_date'"
				               select="$publication-date"/>
			</xsl:map>
		</xsl:if>
	</xsl:function>


	<xsl:function name="slsFn:tei-source-metadata-map" as="map(*)?">
		<!-- * Constructs source-related metadata from a TEI document. * -->
		<xsl:param name="doc" as="document-node()?"/>

		<xsl:variable name="source-desc" as="element(tei:sourceDesc)?"
		              select="$doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                          /tei:sourceDesc"/>

		<xsl:variable name="source-archive" as="xs:string?"
		              select="let $ms-identifier := $source-desc/tei:msDesc/tei:msIdentifier
		                      return
		                          if (exists($ms-identifier))
		                              then (let $norm-ms-name := if (exists($ms-identifier/tei:msName))
		                                                             then normalize-space(string($ms-identifier/tei:msName))
		                                                         else (),
		                                        $ms-name := if (boolean($norm-ms-name))
		                                                        then '”' || $norm-ms-name || '”'
		                                                    else (),
		                                        $parts := ($ms-identifier/tei:collection,
		                                                   $ms-identifier/tei:repository,
		                                                   $ms-identifier/tei:institution,
		                                                   $ms-identifier/tei:settlement,
		                                                   $ms-identifier/tei:country,
		                                                   $ms-name,
		                                                   $ms-identifier/tei:idno)
		                                    return
		                                        $parts ! string(.)
		                                        ! normalize-space(.)
		                                        => string-join(', '))
		                          else ()"/>

		<xsl:variable name="source-bibl" as="xs:string?"
		              select="if (exists($source-desc/tei:bibl))
		                          then slsFn:tei-inline-html($source-desc/tei:bibl[1])
		                      else ()"/>

		<xsl:if test="exists($source-archive) or exists($source-bibl)">
			<xsl:map>
				<xsl:if test="exists($source-archive)">
					<xsl:map-entry key="'source_archive'"
				                   select="$source-archive"/>
				</xsl:if>

				<xsl:if test="exists($source-bibl)">
					<xsl:map-entry key="'source_bibl'"
				                   select="$source-bibl"/>
				</xsl:if>
			</xsl:map>
		</xsl:if>
	</xsl:function>


	<xsl:function name="slsFn:tei-physical-metadata-map" as="map(*)?">
		<!-- * Constructs physical description metadata from a TEI document. * -->
		<xsl:param name="doc" as="document-node()?"/>

		<xsl:variable name="source-desc" as="element(tei:sourceDesc)?"
		              select="$doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                          /tei:sourceDesc"/>

		<xsl:variable name="dim-elem" as="element(tei:dimensions)?"
		              select="($source-desc/tei:msDesc/tei:physDesc/tei:objectDesc
		                           /tei:supportDesc/tei:extent/tei:dimensions)[1]"/>

		<xsl:variable name="phys-dimensions" as="xs:string?"
		              select="if ($dim-elem and $dim-elem/tei:height and $dim-elem/tei:width)
		                          then string($dim-elem/tei:width) || ' × '
		                               || string($dim-elem/tei:height)
		                               || (if ($dim-elem[@unit])
		                                       then (' ' || string($dim-elem/@unit))
		                                   else '')
		                      else ()"/>

		<xsl:variable name="phys-desc" as="element(tei:physDesc)?"
		              select="$source-desc/tei:msDesc/tei:physDesc"/>
		<xsl:variable name="phys-desc-p" as="element(tei:p)*"
		              select="$phys-desc/tei:p"/>
		<xsl:variable name="phys-description" as="xs:string?"
		              select="slsFn:tei-inline-html-from-seq($phys-desc-p, $phys-desc)"/>

		<xsl:if test="exists($phys-dimensions) or exists($phys-description)">
			<xsl:map>
				<xsl:if test="exists($phys-dimensions)">
					<xsl:map-entry key="'phys_dimensions'"
				                   select="$phys-dimensions"/>
				</xsl:if>

				<xsl:if test="exists($phys-description)">
					<xsl:map-entry key="'phys_description'"
					               select="$phys-description"/>
				</xsl:if>
			</xsl:map>
		</xsl:if>
	</xsl:function>


	<xsl:function name="slsFn:tei-availability-metadata-map" as="map(*)">
		<!-- * Constructs a metadata map from the language-appropriate
			 * tei:availability element in a TEI document.
			 *
			 * @param $doc
			 * An optional TEI XML document node.
			 *
			 * @return
			 * A map containing licence, licence_encoding, licence_work and
			 * rights entries when the corresponding values exist. * -->
		<xsl:param name="doc" as="document-node()?"/>

		<xsl:variable name="availability-elem" as="element(tei:availability)?"
		              select="let $pubStmt-elem := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt
		                      return
		                          ($pubStmt-elem/tei:availability[@xml:lang eq $meta-lang][1],
			                       $pubStmt-elem/tei:availability[not(@xml:lang)][1],
			                       $pubStmt-elem/tei:availability[1])[1]"/>

		<xsl:variable name="licence-elem" as="element(*)?"
		              select="($availability-elem/tei:ab[@type eq 'licence'][1],
			                   $availability-elem/tei:licence[1])[1]"/>

		<xsl:variable name="licence" as="xs:string?"
		              select="if ($licence-elem instance of element(tei:licence))
		                          then if (not($licence-elem//tei:ref))
		                                   then slsFn:tei-node-to-html($licence-elem, ())
		                               else slsFn:tei-inline-html($licence-elem)
		                      else ()"/>

		<xsl:variable name="licence-work" as="xs:string?"
		              select="if (exists($licence-elem[@subtype eq 'sourceWork']))
		                          then if (not($licence-elem//tei:ref))
		                                   then normalize-space(string($licence-elem))
		                               else slsFn:tei-inline-html($licence-elem)
		                      else ()"/>

		<xsl:variable name="licence-encoding" as="xs:string?"
		              select="if (exists($licence-elem[@subtype eq 'teiEncoding']))
		                          then if (not($licence-elem//tei:ref))
		                                   then normalize-space(string($licence-elem))
		                               else slsFn:tei-inline-html($licence-elem)
		                      else ()"/>

		<xsl:variable name="rights-elem" as="element(tei:ab)?"
		              select="($availability-elem/tei:ab[@type eq 'rights'][@subtype eq 'sourceWork'],
		                       $availability-elem/tei:ab[@type eq 'rights'][1])[1]"/>

		<xsl:variable name="rights" as="xs:string?"
		              select="if (exists($rights-elem) and boolean(normalize-space(string($rights-elem))))
		                          then if (not($rights-elem//tei:ref))
		                                   then normalize-space(string($rights-elem))
		                               else slsFn:tei-inline-html($rights-elem)
		                      else ()"/>

		<xsl:map>
			<xsl:if test="exists($licence)">
				<xsl:map-entry key="'licence'"
			                   select="$licence"/>
			</xsl:if>

			<xsl:if test="exists($licence-encoding)">
				<xsl:map-entry key="'licence_encoding'"
			                   select="$licence-encoding"/>
			</xsl:if>

			<xsl:if test="exists($licence-work)">
				<xsl:map-entry key="'licence_work'"
			                   select="$licence-work"/>
			</xsl:if>

			<xsl:if test="exists($rights)">
				<xsl:map-entry key="'rights'"
			                   select="$rights"/>
			</xsl:if>
		</xsl:map>
	</xsl:function>


	<xsl:function name="slsFn:tei-responsibility-metadata-map" as="map(xs:string, array(map(*)?))?">
		<!-- * Constructs a metadata map from the tei:respStmt element
			 * nodes in a TEI document.
			 *
			 * @param $doc
			 * An optional TEI XML document node.
			 *
			 * @return
			 * A map containing a 'responsibility' key with an array
			 * of maps as value. * -->
		<xsl:param name="doc" as="document-node()?"/>
		
		<xsl:variable name="responsibility" as="array(map(*)?)"
		              select="array {
		                          for $resp-stmt in $doc/tei:TEI/tei:teiHeader
		                              /tei:fileDesc/tei:titleStmt/tei:respStmt
		                          return slsFn:resp-stmt-map($resp-stmt)
		                      }"/>

		<xsl:if test="array:size($responsibility) gt 0">
			<xsl:map>
				<xsl:map-entry key="'responsibility'"
				               select="$responsibility"/>
			</xsl:map>
		</xsl:if>
	</xsl:function>
	
	
	<xsl:function name="slsFn:resp-stmt-map" as="map(*)?">
		<!-- * Constructs a language-appropriate map from a single
			 * tei:respStmt element.
			 *
			 * @param $resp-stmt
			 * A tei:respStmt element node.
			 *
			 * @return
			 * A map containing a 'resp' key with a string value,
			 * and a 'names' key with an array of strings value. * -->
		<xsl:param name="resp-stmt" as="element(tei:respStmt)"/>
		
		<xsl:variable name="resp" as="xs:string?"
		              select="let $resp-elem := ($resp-stmt/tei:resp[@xml:lang eq $meta-lang][1],
		                                         $resp-stmt/tei:resp[not(@xml:lang)][1])[1],
		                          $norm-resp := normalize-space($resp-elem/string()),
		                          $resp-cont := if (boolean($norm-resp))
		                                            then $norm-resp
		                                        else (),
		                          $last-char := substring($resp-cont, string-length($resp-cont))
		                      return
		                          if (($last-char) = (':', '.'))
		                              then substring($resp-cont, 1, string-length($resp-cont) - 1)
		                          else $resp-cont
		                      "/>

		<xsl:variable name="name-elems" as="element(*)"
		              select="($resp-stmt/tei:name, $resp-stmt/tei:persName)"/>

		<xsl:variable name="names" as="array(xs:string)"
		              select="array {
		                          for $n in $name-elems
		                          return slsFn:tei-node-to-html($n, ())
		                      }"/>
		<xsl:if test="exists($resp) and array:size($names) gt 0">
			<xsl:map>
				<xsl:map-entry key="'resp'"
				               select="$resp"/>
				<xsl:map-entry key="'names'"
				               select="$names"/>
			</xsl:map>
		</xsl:if>
		
	</xsl:function>


	<xsl:function name="slsFn:facsimile-map" as="map(*)">
		<!-- * Constructs the normalized metadata map for a single
			 * facsimile entry.
			 *
			 * The input parameter $facs is expected to be a map representing
			 * one facsimile from $db-meta?facsimiles. The function copies
			 * selected facsimile properties into a new map and may compute
			 * or normalize individual values, such as whitespace-normalized
			 * titles.
			 * 
			 * @param $facs
			 * A facsimile metadata map.
			 * 
			 * @return
			 * A map containing the facsimile fields used in the generated
			 * output. * -->
		<xsl:param name="facs" as="map(*)"/>
		
		<xsl:variable name="facs-title"
		              select="normalize-space($facs?title)"/>
		<xsl:variable name="facs-description"
		              select="normalize-space($facs?description)"/>
		<xsl:variable name="facs-external-url"
		              select="normalize-space($facs?external_url)"/>
		<xsl:variable name="facs-section-id"
		              select="if (exists($facs?section_id) and $facs?section_id eq 0)
				                  then ()
				              else $facs?section_id"/>

		<xsl:map>
			<xsl:map-entry key="'id'" select="$facs?id"/>
			
			<xsl:map-entry key="'facs_coll_id'" select="$facs?facs_coll_id"/>
			
			<xsl:if test="boolean($facs-title)">
				<xsl:map-entry key="'title'" select="$facs-title"/>
			</xsl:if>
			
			<xsl:if test="boolean($facs-description)">
				<xsl:map-entry key="'description'" select="$facs-description"/>
			</xsl:if>
			
			<xsl:if test="boolean($facs-external-url)">
				<xsl:map-entry key="'external_url'" select="$facs-external-url"/>
			</xsl:if>
			
			<xsl:if test="exists($facs?publication_manuscript_id)">
				<xsl:map-entry key="'publication_manuscript_id'" select="$facs?publication_manuscript_id"/>
			</xsl:if>
			
			<xsl:if test="exists($facs?publication_variant_id)">
				<xsl:map-entry key="'publication_variant_id'" select="$facs?publication_variant_id"/>
			</xsl:if>
			
			<xsl:if test="exists($facs-section-id)">
				<xsl:map-entry key="'section_id'" select="$facs-section-id"/>
			</xsl:if>
			
			<xsl:if test="exists($facs?priority)">
				<xsl:map-entry key="'priority'" select="$facs?priority"/>
			</xsl:if>
			
			<xsl:if test="exists($facs?page_nr)">
				<xsl:map-entry key="'page_nr'" select="$facs?page_nr"/>
			</xsl:if>
			
			<xsl:if test="exists($facs?number_of_images)">
				<xsl:map-entry key="'number_of_images'" select="$facs?number_of_images"/>
			</xsl:if>
		</xsl:map>
	</xsl:function>


	<xsl:function name="slsFn:manuscript-map" as="map(*)">
		<!-- * Constructs the normalized metadata map for a single
			 * manuscript entry.
			 *
			 * The input parameter $ms is expected to be a map representing
			 * one manuscript from $db-meta?manuscripts. The function copies
			 * selected manuscript properties into a new map and may compute
			 * or normalize individual values, such as whitespace-normalized
			 * titles.
			 * 
			 * @param $ms
			 * A manuscript metadata map.
			 * 
			 * @return
			 * A map containing the manuscript fields used in the generated
			 * output:
			 * id, title, section_id, sort_order, language, and document or
			 * availability metadata when present. * -->
		<xsl:param name="ms" as="map(*)"/>

		<xsl:variable name="ms-title"
		              select="normalize-space($ms?title)"/>
		<xsl:variable name="ms-language-code"
		              select="normalize-space($ms?language)"/>
		<xsl:variable name="ms-section-id"
		              select="if (exists($ms?section_id) and $ms?section_id eq 0)
				                  then ()
				              else $ms?section_id"/>
		
		<xsl:variable name="ms-doc" as="document-node()?"
		              select="slsFn:doc-if-available($ms?original_filename_uri)"/>

		<xsl:map>
			<xsl:map-entry key="'id'" select="$ms?id"/>
			
			<xsl:if test="boolean($ms-title)">
				<xsl:map-entry key="'title'" select="$ms-title"/>
			</xsl:if>
			
			<xsl:if test="exists($ms-section-id)">
				<xsl:map-entry key="'section_id'" select="$ms-section-id"/>
			</xsl:if>
			
			<xsl:if test="exists($ms?sort_order)">
				<xsl:map-entry key="'sort_order'" select="$ms?sort_order"/>
			</xsl:if>
			
			<xsl:if test="boolean($ms-language-code)">
				<xsl:map-entry key="'language'"
					           select="slsFn:language-name(
					                       slsFn:normalise-language($ms-language-code),
					                       $meta-lang
					                   )"/>
			</xsl:if>

			<xsl:sequence select="slsFn:tei-author-metadata-map($ms-doc)"/>

			<xsl:sequence select="slsFn:tei-date-metadata-map($ms-doc, (), true())"/>

			<xsl:sequence select="slsFn:tei-source-metadata-map($ms-doc)"/>

			<xsl:sequence select="slsFn:tei-physical-metadata-map($ms-doc)"/>

			<xsl:sequence select="slsFn:tei-availability-metadata-map($ms-doc)"/>
			
			<xsl:sequence select="slsFn:tei-responsibility-metadata-map($ms-doc)"/>
		</xsl:map>
	</xsl:function>


	<xsl:function name="slsFn:variant-map" as="map(*)">
		<!-- * Constructs the normalized metadata map for a single
			 * variant entry.
			 *
			 * The input parameter $var is expected to be a map representing
			 * one variant from $db-meta?variants. The function copies
			 * selected variant properties into a new map and may compute
			 * or normalize individual values, such as whitespace-normalized
			 * titles.
			 * 
			 * @param $var
			 * A variant metadata map.
			 * 
			 * @return
			 * A map containing the variant fields used in the generated
			 * output:
			 * id, title, section_id, sort_order, type, language, author,
			 * orig_date, source_archive, source_bibl, phys_description,
			 * and phys_dimensions when present. * -->
		<xsl:param name="var" as="map(*)"/>

		<xsl:variable name="var-title"
		              select="normalize-space($var?title)"/>
		<xsl:variable name="var-section-id"
		              select="if (exists($var?section_id) and $var?section_id eq 0)
				                  then ()
				              else $var?section_id"/>

		<xsl:variable name="var-doc" as="document-node()?"
		              select="slsFn:doc-if-available($var?original_filename_uri)"/>
		
		<xsl:variable name="var-language-code"
		              select="normalize-space($var-doc/tei:TEI/tei:text/@xml:lang)"/>

		<xsl:map>
			<xsl:map-entry key="'id'" select="$var?id"/>
			
			<xsl:if test="boolean($var-title)">
				<xsl:map-entry key="'title'" select="$var-title"/>
			</xsl:if>
			
			<xsl:if test="exists($var-section-id)">
				<xsl:map-entry key="'section_id'" select="$var-section-id"/>
			</xsl:if>
			
			<xsl:if test="exists($var?sort_order)">
				<xsl:map-entry key="'sort_order'" select="$var?sort_order"/>
			</xsl:if>
			
			<xsl:if test="exists($var?type)">
				<xsl:map-entry key="'type'" select="$var?type"/>
			</xsl:if>
			
			<xsl:if test="boolean($var-language-code)">
				<xsl:map-entry key="'language'"
					           select="slsFn:language-name(
					                       slsFn:normalise-language($var-language-code),
					                       $meta-lang
					                   )"/>
			</xsl:if>

			<xsl:sequence select="slsFn:tei-author-metadata-map($var-doc)"/>

			<xsl:sequence select="slsFn:tei-date-metadata-map($var-doc, (), true())"/>

			<xsl:sequence select="slsFn:tei-source-metadata-map($var-doc)"/>

			<xsl:sequence select="slsFn:tei-physical-metadata-map($var-doc)"/>

			<xsl:sequence select="slsFn:tei-availability-metadata-map($var-doc)"/>
			
			<xsl:sequence select="slsFn:tei-responsibility-metadata-map($var-doc)"/>
		</xsl:map>
	</xsl:function>


</xsl:stylesheet>
