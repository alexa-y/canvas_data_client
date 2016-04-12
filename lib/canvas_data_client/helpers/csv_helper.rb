require 'csv'

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
        file_path = download_raw_file(file_mapping, dir)
        File.foreach(file_path) do |row|
          split_row = row.gsub(/\n/, '').split(/\t/)
          split_row.fill(nil, split_row.length...columns.length) if split_row.length < columns.length
          csv << split_row.map { |col| col == '\\N' ? nil : col }
        end
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
    resp = RestClient.get file_mapping['url']
    file_path = "#{dir}/#{File.basename(file_mapping['filename'], '.gz')}"
    File.open(file_path, 'w') do |file|
      file.write Zlib::GzipReader.new(StringIO.new(resp)).read
    end
    file_path
  end
end
