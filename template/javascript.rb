unless ["importmap", "bun"].include?(options[:javascript])
  run "npm install -g corepack"
  run "corepack enable"
  run "corepack prepare yarn@stable --activate"

  create_file ".yarnrc.yml", <<~YAML
    nodeLinker: pnpm
  YAML
end
