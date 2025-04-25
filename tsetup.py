#!/usr/bin/env python3
"""tsetup.

Usage:
  tsetup.py [-c <config>] [-n <name>] [-p <phase>] [-o <dir>] [-t <dir>] [-w <dir>] [-d...] [-s <file>] [-r | -e ] [-h]
  tsetup.py (-h | --help)

Options:
  -c <config> --config=<config>  Config file [default: config.yml].
  -n <name> --name=<name>        Run a specific template name [default: _all].
  -p <phase> --phase=<phase>     Run a phase [default: _all].
  -o <dir> --output=<dir>        Output dir of template [default: _output].
  -t <dir> --templates=<dir>     Templates dir [default: templates].
  -w <dir> --cwd=<dir>           Current working directory.
  -s <file> --state <file>       State file path [default: .state.json].
  -r --render-only               Render templates only without command execution.
  -e --execute-only              Execute commands only without template rendering.
  -d --debug                     Debug level, Can be repeated be more verbose upto to 4 times.
  -h --help                      Show this screen.
"""


import os
import yaml
import subprocess
import json

from yaml.loader import SafeLoader
from jinja2 import Environment, FileSystemLoader, StrictUndefined
from docopt import docopt


class config():
  def __init__(self):
    self.arguments = None
    self.data = {}
  def set(self, arguments):
    self.arguments = arguments
    debug("Before evaluation: " + str(arguments), 3)
    if arguments["--cwd"] is None:
      arguments["--cwd"] = os.getcwd()
    # Normalize paths
    arguments["--config"] = handle_path(arguments["--cwd"], arguments["--config"], True)
    arguments["--output"] = handle_path(arguments["--cwd"], arguments["--output"], True)
    arguments["--templates"] = handle_path(arguments["--cwd"], arguments["--templates"], True)
    print(f": Config path : {arguments['--config']}\n: Templates path : {arguments['--templates']}\n: Output path : {arguments['--output']}\n")
    debug("After evaluation: " + str(arguments), 4)
    try:
      with  open(c.arguments["--state"], "r") as f:
        self.data = json.load(f)
    except json.decoder.JSONDecodeError:
      pass
    except FileNotFoundError:
      pass

  def _flush(self):
      with open(c.arguments["--state"], "w") as f:
        json.dump(self.data, f)

  def _lock(self):
    pass
  def _unlock():
    pass

  def _append_to_list(self, key, value, index):
    if not self.data.get(key, False):
      self.data[key] = []
    if len(self.data[key]) > index:
      self.data[key][index] = value
    else:
      self.data[key].append(value)

  def store(self, key, value, index=None):
    if index is not None:
      self._append_to_list(key,value, index)
    else:
      self.data[key] = value
    self._flush()
  
  def retrieve(self, key, error_on_not_found=False, index=None):
    if index is not None and isinstance(self.data.get(key, None), list) and len(self.data[key]) >= index: 
      value_of_data = self.data[key][index]
    elif index is None:
      value_of_data = self.data.get(key, None)
    else:
      value_of_data = None

    if error_on_not_found and value_of_data is None:
      raise KeyError(f"Key not found in state '{key}'")
    return value_of_data

  def save_output(self, template, r, index):
    if not template.get("save", False):
      return
    self.store(template["save"],r,index)

def debug(msg, level):
  if c.arguments["--debug"] >= level:
    print(f"(Debug {level}): {msg}")

def handle_path(cwd, path, check_path=False):
  new_path=path
  if not os.path.isabs(new_path):
    new_path = os.path.join(cwd, new_path)
  if check_path and not os.path.exists(new_path):
    raise Exception(f"Invalid path provided, path does not exist. '{new_path}'")
  return new_path

def run_command(name, cmd, ignore_error=False):
  r = {"stdout": None, "stderr": None, "rc": None}
  print(f"[{name}][command]: {cmd}")
  process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, shell=True)
  r["stdout"] = str(process.stdout)
  r["stderr"] = str(process.stderr)
  r["rc"] = int(process.returncode)
  debug(r["stdout"], 2)
  # debug(arguments, f"command {name} returned: {r['rc']}\nstdout:\n{r['stdout']}\nstderr:\n{r['stderr']}\n", 4)
  if r['rc'] == 0 or ignore_error:
    return r
  raise Exception("Error execution")

def get_dic_item_with_notation(data, notation):
  exploded = notation.split(".")
  value = data
  for current_level in exploded:
    try:
      if current_level.isnumeric():
        current_level = int(current_level)
      value = value[current_level]
    except KeyError:
      raise KeyError(f"Failed to get dic item '{current_level}' from notation '{notation}'")
  return value

def from_json(json_string, filter=None):
    jsonDict = json.loads(str(json_string))
    if not filter:
        return jsonDict
    return get_dic_item_with_notation(jsonDict, filter)

def render_template(data, name, item, template):
  v = {"config": data, "item": item, "state": c.data}
  template_file = template.get('template_filename', None)
  output_file = template.get('output_filename', None)
  file_loader = FileSystemLoader(c.arguments["--templates"])
  env = Environment(loader=file_loader, undefined=StrictUndefined)
  env.filters['from_json'] = from_json

  if template_file and output_file:
    print(f"[{name}][template]: {template_file}")
    # Render template
    t = env.get_template(template_file)
    rendered_output = t.render(v)
    # Output filename interpolate
    t = env.from_string(output_file)
    output_file = t.render(v)
    # Save output
    with open(f"{c.arguments['--output']}/{output_file}", "w") as fh:
      fh.write(rendered_output)

  if 'cmd' not in template:
    return None
  # cmd interpolate
  t = env.from_string(template['cmd'] )
  return t.render(v)

def prepare_template(data, template,):
    cmd = None
    r = None
    if 'iterate' in template:
      iterate_data = get_dic_item_with_notation(data, template['iterate'])
      cmd_run_once = template.get('cmd_once', False)
      for item_number, item in enumerate(iterate_data):
        name = f"{template['name']}-{item_number}"
        cmd = render_template(data, name, item, template)
        if not cmd_run_once and cmd: # run in every iteration
          r = run_command(name, cmd)
          c.save_output(template, r, item_number)
      # run once only after loop
      if cmd_run_once and cmd:
        r = run_command(template['name'], cmd)
        c.save_output(template, r, None)
    else:
      cmd = render_template(data, template['name'], None, template)
      if cmd:
        r =run_command(template['name'], cmd)
        c.save_output(template, r, None)

def filter_templates(templates):
  if c.arguments["--phase"] != "_all":
    templates = filter(lambda x: c.arguments["--phase"] in x.get("phase", ""), templates)
  if c.arguments["--name"] != "_all":
    templates = filter(lambda x: c.arguments["--name"] in x.get("name", ""), templates)
  return list(templates)

def load_config():
  with open(c.arguments["--config"]) as f:
    data = yaml.load(f, Loader=SafeLoader)
  if 'templates' not in data:
    print("No templates in config. bye")
    exit(1)
  filtered_template = filter_templates(data['templates'])
  if len(filtered_template) == 0:
    print("too restricted filters, returned no templates")
    exit(1)
  for template_number, template in enumerate(filtered_template):
    if 'name' not in template:
        template['name'] = f"T{template_number}"
    prepare_template(data, template)

c = config()
if __name__ == '__main__':
  c.set(docopt(__doc__))
  load_config()
