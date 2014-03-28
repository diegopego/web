
class Language

  def initialize(dojo, name)
    @dojo,@name = dojo,name
  end

  attr_reader :dojo, :name

  def exists?
    paas.exists?(self)
  end

  def display_name
    manifest['language_name'] || @name
  end

  def display_unit_test_framework
    manifest['test_name'] || unit_test_framework
  end

  def visible_files
    Hash[visible_filenames.collect{ |filename|
      [ filename, read(filename) ]
    }]
  end

  def support_filenames
    manifest['support_filenames'] || [ ]
  end

  def highlight_filenames
    manifest['highlight_filenames'] || [ ]
  end

  def unit_test_framework
    manifest['unit_test_framework']
  end

  def tab
    " " * tab_size
  end

  def tab_size
    manifest['tab_size'] || 4
  end

  def visible_filenames
    manifest['visible_filenames'] || [ ]
  end

  def manifest
    @manifest ||= JSON.parse(read('manifest.json'))
  end

private

  def read(filename)
    paas.disk_read(self, filename)
  end

  def paas
    dojo.paas
  end

end
