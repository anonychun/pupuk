unless ["importmap", "bun"].include?(options[:javascript])
  create_file ".yarnrc.yml", <<~YAML
    nodeLinker: pnpm
  YAML
end
