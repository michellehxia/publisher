# Linkables
#
# Note that the functionality to fetch tags from the publishing-api and
# transform them into a structure for a dropdown in a form is duplicated
# across apps like content-tagger and Whitehall. Once we've migrated all apps
# to use `content_id`, we may move this functionality into a gem.
module Tagging
  module Linkables
    def self.topics
      @@topics ||= get_tags_of_type('topic')
    end

    def self.mainstream_browse_pages
      @@mainstream_browse_pages ||= get_tags_of_type('mainstream_browse_page')
    end

    def self.get_tags_of_type(document_type)
      items = Services.publishing_api.get_linkables(format: document_type)

      items = items.map do |item|
        title = item.fetch('internal_name')

        # In Topics and Browse pages, the "internal name" is generated in the
        # form: "Parent title / Child title". Because currently we only show
        # documents on child-topic pages (like /topic/animal-welfare/pets), we
        # only allow tagging to those tags in this application. That's why we
        # filter out the top-level (which don't have the slash) topics/browse
        # pages here. This of course is temporary, until we've introduced a
        # global taxonomy that will allow editors to tag to any level.
        next unless title.include?(' / ')

        title = "#{title} (draft)" if item.fetch("publication_state") == "draft"

        [title, item.fetch('content_id')]
      end

      items
        .compact
        .sort_by(&:first)
        .group_by { |entry| entry.first.split(' / ').first }
    end
  end
end
