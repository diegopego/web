require 'test_helper'

# > cd cyberdojo/test
# > ruby functional/dojo_tests.rb

class DojoTests < ActionController::TestCase

  Root_test_folder = 'test_dojos'

  def root_test_folder_reset
    system("rm -rf #{Root_test_folder}")
    Dir.mkdir Root_test_folder
  end

  def make_params
    { :dojo_name => 'Jon Jagger', 
      :dojo_root => Dir.getwd + '/' + Root_test_folder,
      :filesets_root => Dir.getwd + '/../filesets'
    }
  end
  
  def test_that_creating_a_new_dojo_succeeds_and_creates_root_folder
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    dojo = Dojo.new(params)
    assert File.exists?(dojo.folder), 'inner/outer folder created'
  end
  
  def test_that_trying_to_create_an_existing_dojo_fails
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    assert !Dojo::create(params)    
  end
  
  def test_that_configuring_a_new_dojo_creates_three_core_files
    root_test_folder_reset
    params = make_params
    params['duration'] = 60
    params['rotation'] = 5
    params['kata'] = { 0 => 'Unsplice' }
    params['language'] = { 0 => 'C++' }    
    assert Dojo::create(params)
    Dojo::configure(params)
    dojo = Dojo.new(params)
    assert File.exists?(dojo.ladder_filename), 'ladder.rb created'
    assert File.exists?(dojo.rotation_filename), 'rotation.rb created'
    assert File.exists?(dojo.manifest_filename), 'manifest.rb created'
  end

  def test_that_a_player_can_create_a_new_avatar_in_a_new_dojo
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    dojo = Dojo.new(params)
    filesets = {}
    filesets['kata'] = FileSet.new(params[:filesets_root], 'kata').choices.shuffle[0]
    filesets['language'] = FileSet.new(params[:filesets_root], 'language').choices.shuffle[0]
    avatar = Avatar.new(dojo, nil, filesets)
    assert File.exists?(avatar.folder), 'avatar folder created'    
  end
  
  def test_that_a_player_can_create_a_new_dojo_with_specified_duration
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    specified_duration = 65
    params['duration'] = specified_duration
    params['rotation'] = 5
    params['kata'] = { 0 => 'Unsplice' }
    params['language'] = { 0 => 'C++' }
    Dojo::configure(params)
    dojo = Dojo.new(params)
    manifest = eval IO.read(dojo.manifest_filename)
    assert_equal specified_duration, manifest[:minutes_duration]    
  end
  
  def test_that_a_player_can_create_a_new_dojo_with_forever_duration
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    years_10 = 10*365*24*60
    params['duration'] = years_10
    params['rotation'] = 5
    params['kata'] = { 0 => 'Unsplice' }
    params['language'] = { 0 => 'C++' }
    Dojo::configure(params)
    dojo = Dojo.new(params)
    manifest = eval IO.read(dojo.manifest_filename)
    assert_equal years_10, manifest[:minutes_duration]    
    end
  
  def test_that_a_player_can_create_a_new_dojo_with_specified_rotation
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    specified_rotation = 10
    params['rotation'] = specified_rotation
    params['duration'] = 60
    params['kata'] = { 0 => 'Unsplice' }
    params['language'] = { 0 => 'C++' }
    Dojo::configure(params)
    dojo = Dojo.new(params)
    manifest = eval IO.read(dojo.manifest_filename)
    assert_equal specified_rotation, manifest[:minutes_per_rotation]    
  end
  
  def test_that_a_player_can_create_a_new_dojo_with_rotation_of_none
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    years_10 = 10*365*24*60
    params['rotation'] = years_10
    params['duration'] = 60
    params['kata'] = { 0 => 'Unsplice' }
    params['language'] = { 0 => 'C++' }
    Dojo::configure(params)
    dojo = Dojo.new(params)
    manifest = eval IO.read(dojo.manifest_filename)
    assert_equal years_10, manifest[:minutes_per_rotation]    
  end

  def test_that_a_player_can_create_a_new_avatar_with_specified_kata
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    dojo = Dojo.new(params)
    kata_choice = 'Unsplice (*)'
    expected_filesets = { 'kata' => kata_choice }
    avatar = Avatar.new(dojo, nil, expected_filesets)
    actual_filesets = eval IO.read(avatar.folder + '/' + 'filesets.rb')
    assert_equal kata_choice, actual_filesets['kata']
  end
  
  def test_that_a_player_can_create_a_new_avatar_with_specified_language
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    dojo = Dojo.new(params)
    language_choice = 'Ruby'
    expected_filesets = { 'language' => language_choice }
    avatar = Avatar.new(dojo, nil, expected_filesets)
    actual_filesets = eval IO.read(avatar.folder + '/' + 'filesets.rb')
    assert_equal language_choice, actual_filesets['language']
  end
  
  def test_that_a_player_can_create_a_new_avatar_with_specified_kata_and_language
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    dojo = Dojo.new(params)
    kata_choice = 'Unsplice (*)'
    language_choice = 'Ruby'
    expected_filesets = { 'kata' => kata_choice, 'language' => language_choice }
    avatar = Avatar.new(dojo, nil, expected_filesets)
    actual_filesets = eval IO.read(avatar.folder + '/' + 'filesets.rb')
    assert_equal kata_choice, actual_filesets['kata']
    assert_equal language_choice, actual_filesets['language']
  end
  
  
  def test_makefile_filter_filename_not_makefile
     name     = 'not_makefile'
     content  = "    abc"
     actual   = TestRunner.makefile_filter(name, content)
     expected = "    abc"
     assert_equal expected, actual
  end

  def test_makefile_filter_filename_is_makefile
     name     = 'makefile'
     content  = "    abc"
     actual   = TestRunner.makefile_filter(name, content)
     expected = "\tabc"
     assert_equal expected, actual
  end

  def test_makefile_filter_filename_is_Makefile_with_uppercase_M
     name     = 'Makefile'
     content  = "    abc"
     actual   = TestRunner.makefile_filter(name, content)
     expected = "\tabc"
     assert_equal expected, actual
  end

end
