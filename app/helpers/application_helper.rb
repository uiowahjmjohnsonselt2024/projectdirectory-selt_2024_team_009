module ApplicationHelper
    # Returns the full title for each page
    def full_title(page_title = '')
        base_title = "Shards of the Grid"
        if page_title.empty?
            base_title
        else
            "#{page_title} | #{base_title}"
        end
    end
end
