# Hasta

<b>HA</b>doop <b>S</b>treaming <b>T</b>est h<b>A</b>rness for Amazon EMR

A test harness for running [Hadoop Streaming](http://hadoop.apache.org/docs/r1.2.1/streaming.html) jobs written in Ruby without running Hadoop.
The test harness understands the [Amazon Data Pipeline](http://aws.amazon.com/datapipeline/) and [Elastic Map Reduce](http://aws.amazon.com/elasticmapreduce/) (EMR) JSON definition format and can automatically parse the details of a job out of Data Pipeline configuration file.

## Installation

Add this line to your application's Gemfile:

    gem 'hasta'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hasta

## Usage

1. Require the Hasta Rake tasks in your project's Rakefile

   ```ruby
   require 'hasta/tasks'
   ```

2. Add the `Hasta::Tasks:Runner` task to your project's Rakefile

  ```ruby
  Hasta::Tasks::Runner.new do |task, opts|
    task.definition_file = <path-to-AWS-datapipeline-definition-json-file>
    task.job_id = opts[:job_id]
    task.scheduled_start_time = Time.parse(opts[:scheduled_start_time])
    task.project_root = File.dirname(__FILE__)
  end
```
3. (Optional) Register a custom `sort_by` for the mapper results by adding the following block of code to your project's Rakefile

  ```ruby
  Hasta.configure do |config|
    config.sort_by { |line| # TODO: define the sort key for the mapper results }
  end
```
4. Run the test from the command line by calling:

  ```
% rake runner[<job-id>]
```
  or
  ```
% rake runner[<job-id>,<scheduled-start-time>]
```

## Configuration

The global configuration for Hasta can be updated at any time.
The following snippet illustrates how to update the configuration, which values are mandatory, and which values have defaults.

```ruby
Hasta.configure do |config|
  # mandatory
  config.project_root = nil

  # optional
  config.sort_by = nil
  config.local_storage_root = '~/fog'
  config.project_steps = 'steps'
  config.logger = Logger.new(STDOUT)
end
```

## Data

All of the data read and written by EMR jobs is stored in [S3](http://aws.amazon.com/s3/).
Hasta uses the S3 URIs contained in the Data Pipeline definition file for all of its reads and writes.
When reading data, it will first look on the local filesystem.
If the requested S3 URI is not found locally, it will look for it on S3.
Hasta never writes data to S3, only to the local filesytem.

Hasta uses [Fog](http://fog.io/)'s [local storage provider](https://github.com/fog/fog/blob/master/lib/fog/local/storage.rb) to read and write data to the local filesystem using S3 URIs.
The root directory for the local storage is controlled by the `Hasta.local_storage_root` configuration property, which is set to `~/fog` by default.

Hasta reads all of its input data from the S3 paths specified in the AWS datapipline definition file.
If you wish to use different data for an input, you need to put that data into the local directory that corresponds to the S3 path in the definition file.

To control which credentials Hasta is using when communicating with S3, update your `~/.fog` file or set the `FOG_CREDENTIAL` environment variable to the appropriate credential.

## Execution

Hasta sets up the environent variables specified by the `-cmdenv` switch in the job definition.
It also pulls down all cache files from S3 and stores them in local S3 storage.
For all cache files that do no have a `.rb` file extension, an environment variable is added to the `ENV` that points to the absolute path of the local file.

### Example
Given the following `cacheFile` parameter:
```
-cacheFile s3://my-bucket/path/to/abbreviations.json#abbreviations.json
```

The following environment variable will be added to the `ENV`:
```
ENV['ABBREVIATIONS_FILE_PATH'] #=> "#{Hasta.local_storage_root}/my-bucket/path/to/abbreviations.json"
```

The parent directory of each cache file that has a `.rb` file extension is added to the `$LOAD_PATH`, so the mapper and reducer can use `require` statements to load the code in these files.

Hasta executes the local EMR job in a forked subprocess.
This isolates each job and prevents the modifications to `ENV` and `$LOAD_PATH` described above from leaking into the parent process.

The output of the mapper is sorted before it is processed by the reducer.
By default, the mapper output is sorted according to its natural sort order.
If the objects produced by the mapper are not naturally sortable or a different sort ordering is required, the `Hasta.sort_by` property can be set to change how the mapper output gets sorted before it is processed by the reducer.
```ruby
Hasta.configure do |config|
  # sort the keys in case-insensitive alphabetical order
  config.sort_by { |key| key.upcase }
end
```

## Requirements

### Mappers
1. must implement the following interface
```ruby
# @param [String] the line to map
# @return the resulting object, or nil if input should be ignored
map(line)
```

### Reducers
1. must implement one of the following interfaces
```ruby
# @param [Enumerator] an enumerator over all of the input objects
# @yield [String] gives each reducer output line to the block
reduce_over(enumerator, &block)
```
or
```ruby
# @param [String] the reducer input line
# @return [Array<String>] an array of reducer output lines (possibly empty)
reduce(line)
```

### Mappers and Reducers
1. must be stand-alone Ruby scripts
2. must be defined in the `Hasta.project_root`/`Hasta.project_steps` directory
3. must be defined in a file that follows the snake case naming convention
4. the class name of the mapper or reducer must be the camel case version of the name of the file in which it is defined
5. the class name must be in the global namespace


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2014 Swipely, Inc. See [LICENSE.txt](https://github.com/swipely/hasta/blob/master/LICENSE.txt) for further details.
