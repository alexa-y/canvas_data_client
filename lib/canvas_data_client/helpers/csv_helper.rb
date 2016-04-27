require 'csv'
require 'open-uri'
require 'open_uri_redirections'

module CanvasDataClient::Helpers::CsvHelper
  class TableNotPresentError < StandardError; end

  def download_to_csv_file(dump_id:, table:, path:)
    dump_definition = dump(dump_id)
    schema_definition = schema(dump_definition['schemaVersion'])
    raise TableNotPresentError.new("Table #{table} not present in dump #{dump_id}") unless dump_definition['artifactsByTable'][table]

    csv = CSV.open(path, 'w')
    columns = table_headers(schema_definition, table)
    csv << columns

    Dir.mktmpdir do |dir|
      dump_definition['artifactsByTable'][table]['files'].each do |file_mapping|
        renew_urls(dump_id, table, dump_definition['artifactsByTable'][table]['files']) if url_expired?(file_mapping['url'])
        logger.info("Downloading table file: #{file_mapping['filename']}")
        file_path = download_raw_file(file_mapping, dir)
        logger.info("Processing table file: #{file_mapping['filename']}")
        File.foreach(file_path) do |row|
          split_row = row.gsub(/\n/, '').split(/\t/)
          split_row.fill(nil, split_row.length...columns.length) if split_row.length < columns.length
          csv << split_row.map { |col| col == '\\N' ? nil : col }
        end
        FileUtils.rm_f file_path
      end
    end
  ensure
    csv.close if csv
  end

  def download_latest_to_csv_file(table:, path:)
    latest_dump = latest
    download_to_csv_file dump_id: latest_dump['dumpId'], table: table, path: path
  end

  private
  def table_headers(schema_definition, table)
    schema_definition['schema'].find { |k, v| v['tableName'] == table }.last['columns'].map { |c| c['name'] }
  end

  def download_raw_file(file_mapping, dir)
    resp = open(file_mapping['url'])
    file_path = "#{dir}/#{File.basename(file_mapping['filename'], '.gz')}"
    csv_file_path = "#{dir}/#{File.basename(file_mapping['filename'], '.gz')}.csv"
    if resp.is_a?(StringIO)
      File.open(file_path, 'wb') { |file| file.write(resp.read) }
    else
      FileUtils.cp resp, file_path
    end
    File.open(csv_file_path, 'wb') do |file|
      Zlib::GzipReader.open(file_path) do |gz|
        while !gz.eof?
          file.write gz.readpartial(50_000)
        end
      end
    end
    FileUtils.rm_f file_path
    csv_file_path
  end

  def url_expired?(url)
    uri = URI.parse(url)
    params = CGI::parse(uri.query)
    params['Expires'].first.to_i < (Time.now.to_i + 600)
  end

  def renew_urls(dump_id, table, mappings)
    logger.info("Download URLs have expired.  Pulling dump again to get a fresh set")
    new_definition = dump(dump_id)
    new_definition['artifactsByTable'][table]['files'].each_with_index do |new_mapping, idx|
      mappings[idx]['url'] = new_mapping['url']
    end
  end
end
