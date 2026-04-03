module Jekyll
  class DataPage < Page
    def initialize(site, base, dir, data, name, name_expr, template)
      @site = site
      @base = base
      @dir = dir
      
      filename = name_expr ? data[name_expr].to_s : name
      @name = Jekyll::Utils.slugify(filename) + ".html"
      self.process(@name)
      
      # Создаем виртуальную страницу с указанным макетом (template)
      self.content = ""
      self.data = {}
      self.data['layout'] = template
      self.data.merge!(data)
      self.data['title'] = data['name'] if data.key?('name')
    end
  end

  class DataPageGenerator < Generator
    safe true

    def generate(site)
      return unless site.config['page_gen']

      site.config['page_gen'].each do |data_spec|
        # Читаем настройки из _config.yml
        data_file = data_spec['data']
        template = data_spec['template'] || data_spec['data']
        name_prop = data_spec['name']
        dir = data_spec['dir'] || data_spec['data']

        if site.data.key?(data_file)
          records = site.data[data_file]
          records.each do |record|
            site.pages << DataPage.new(site, site.source, dir, record, nil, name_prop, template)
          end
        end
      end
    end
  end
end
