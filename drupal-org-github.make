; This file was auto-generated by drush make
api = 2
core = 7.x

;@TO-DO: Remove for drupal-org.version
;This is just to try the make file locally and it will be removed in the final version
projects[drupal][version] = 7.22

; Patterns: contrib modules dependencies

projects[libraries][subdir] = "contrib"
projects[libraries][version] = "2.1"

projects[macro][subdir] = "contrib"
projects[macro][version] = "1.0-alpha2"

;This branch of the installation profile is based on 7.x-2.x-dev. This will need to be udpated to point to the new release
;projects[patterns][subdir] = "contrib"
;projects[patterns][version] = "2.x-dev"
; Using the github version instead, to include the parenthood branch and patterns_client/server
projects[patterns][type] = "module"
projects[patterns][subdir] = "custom"
projects[patterns][download][type] = "git"
projects[patterns][download][url] = "git://github.com/QScience/Patterns.git"
projects[patterns][download][branch] = "7.x-2.x"

projects[patterns_client][type] = "module"
projects[patterns_client][subdir] = "custom"
projects[patterns_client][download][type] = "git"
projects[patterns_client][download][url] = "git://github.com/QScience/patterns_client.git"
projects[patterns_client][download][branch] = "parenthood"

projects[patterns_server][type] = "module"
projects[patterns_server][subdir] = "custom"
projects[patterns_server][download][type] = "git"
projects[patterns_server][download][url] = "git://github.com/QScience/patterns_server.git"
projects[patterns_server][download][branch] = "parenthood"

projects[token][subdir] = "contrib"
projects[token][version] = "1.5"

; Default languages offered during the installation.
; Currently not supported, .po files related to Drupal version included in translations

;projects[es][subdir] = "translations"
;projects[zh-hans][subdir] = "translations"


; qscience and qtr: contrib modules dependencies - @TO-DO: ask @qscience list to confirm specific versions
projects[auto_nodetitle][subdir] = "contrib"
projects[auto_nodetitle][version] = "1.0"

projects[entity][subdir] = "contrib"
projects[entity][version] = "1.1"

; Replacing the contrib one for the one in github. @TO-DO: we will need to do this with a patch for the official release
;projects[entityreference][subdir] = "contrib"
;projects[entityreference][version] = "1.0"
projects[entityreference][type] = "module"
projects[entityreference][subdir] = "custom"
projects[entityreference][download][type] = "git"
projects[entityreference][download][url] = "git://github.com/QScience/entityreference_lazyreference.git"
projects[entityreference][download][branch] = "1848496-lazy_reference"

projects[views][subdir] = "contrib"
projects[views][version] = "3.7"

projects[eva][subdir] = "contrib"
projects[eva][version] = "1.2"

projects[filefield_sources][subdir] = "contrib"
projects[filefield_sources][version] = "1.7"

projects[date][subdir] = "contrib"
projects[date][version] = "2.6"

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.3"

projects[plus1][subdir] = "contrib"
projects[plus1][version] = "1.0-alpha1"

projects[votingapi][subdir] = "contrib"
projects[votingapi][version] = "2.11"

; pdfparser: contrib modules dependencies - @TO-DO: ask @qscience list to confirm specific versions
projects[field_remove_item][subdir] = "contrib"
projects[field_remove_item][version] = "1.0-rc1"

; qscience_profile_theme: base theme dependency
projects[shiny][version] = "1.1"

;@TO-DO: Remove for drupal-org.version
; This is the equivalent of the custom modules in the future drupal-org.make file
; Analyze if it is possible to fetch them from Drupal.org or if they should be included in custom instead
projects[qscience][type] = "module"
projects[qscience][subdir] = "custom"
projects[qscience][download][type] = "git"
projects[qscience][download][url] = "git://github.com/QScience/QScience.git"
projects[qscience][download][branch] = "reference_develop"

projects[arxiv][type] = "module"
projects[arxiv][subdir] = "custom"
projects[arxiv][download][type] = "git"
projects[arxiv][download][url] = "git://github.com/QScience/arxiv.git"

projects[qtr][type] = "module"
projects[qtr][subdir] = "custom"
projects[qtr][download][type] = "git"
projects[qtr][download][url] = "https://github.com/QScience/qtr.git"

projects[pdfparser][type] = "module"
projects[pdfparser][subdir] = "custom"
projects[pdfparser][download][type] = "git"
projects[pdfparser][download][url] = "git://github.com/QScience/pdfparser.git"

projects[d2d][type] = "module"
projects[d2d][subdir] = "custom"
projects[d2d][download][type] = "git"
projects[d2d][download][url] = "git://github.com/QScience/d2d.git"

projects[visualscience][type] = "module"
projects[visualscience][subdir] = "custom"
projects[visualscience][download][type] = "git"
projects[visualscience][download][url] = "git://github.com/QScience/VisualScience.git"

; Visualscience custom modules dependencies. @TO-DO: This might disappear with the new branch
;projects[livingscience][type] = "module"
;projects[livingscience][subdir] = "custom"
;projects[livingscience][download][type] = "git"
;projects[livingscience][download][url] = "git://github.com/QScience/livingscience.git"

;projects[user_list][type] = "module"
;projects[user_list][subdir] = "custom"
;projects[user_list][download][type] = "git"
;projects[user_list][download][url] = "git://github.com/QScience/UserList.git"

projects[visualscience_docgraph][type] = "module"
projects[visualscience_docgraph][subdir] = "custom"
projects[visualscience_docgraph][download][type] = "git"
projects[visualscience_docgraph][download][url] = "git://github.com/QScience/visualscience_docgraph.git"

; Adding pils for optional installation of patterns_server
projects[pils][type] = "module"
projects[pils][subdir] = "custom"
projects[pils][download][type] = "git"
projects[pils][download][url] = "git://github.com/QScience/pils.git"

; Libraries

; Spyc (YAML parser): required by patterns_yamlparser submodule
libraries[spyc][download][type] = "get"
libraries[spyc][download][url] = "https://raw.github.com/mustangostang/spyc/master/Spyc.php"
libraries[spyc][directory_name] = "spyc"
libraries[spyc][type] = "library"

; @TO-DO: Revise inclusion for drupal-org.version
; Waiting for answer in issue: http://drupal.org/node/1945806
; Create an optional task in the profile if it is not acceptable in the whitelist 
libraries[codemirror][download][type] = "git"
libraries[codemirror][download][url] = "http://marijnhaverbeke.nl/git/codemirror"
libraries[codemirror][directory_name] = "codemirror"
libraries[codemirror][type] = "library"
