# Hasta
[![travis-ci](https://travis-ci.org/swipely/hasta.png?branch=master)](https://travis-ci.org/swipely/hasta)

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
3. Run the test from the command line by calling:

  ```
% rake runner[<job-id>]
```
  or
  ```
% rake runner[<job-id>,<scheduled-start-time>]
```
  Where `job-id` is the id of the EMR job you are testing and `scheduled-start-time` is an [ISO 8601](http://en.wikipedia.org/wiki/ISO_8601)-formatted time specifying the time to use when interpolating any `@scheduledStartTime` variable references in your pipeline definition file.
  If your pipeline definition file has no `@scheduledStartTime` variable references, there is no need to include a `scheduled-start-time` argument.

## Configuration

The following code snippet illustrates how to update the global Hasta configuration, which values are mandatory, and which values have defaults.  This should go in the Rakefile as well.

```ruby
Hasta.configure do |config|
  # mandatory
  config.project_root = nil

  # optional
  config.local_storage_root = '~/fog'
  config.cache_storage_root = '~/.hasta'
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

## Data Filtering

Hasta automatically filters input data to minimize execution time.
By default, Hasta looks for a file in the current directory named `filter_config.yml` for the filtering configuration.
You can change the filter configuration file by setting the `HASTA_DATA_FILTER_FILE` environment variable.
If you want to disable data filtering, you can set the `HASTA_DATA_FILTERING` environment variable to `OFF`.

### Filter Configuration

The filter configuration file is a YAML file containing a Hash that maps S3 URIs (as Strings) to Arrays of regular expressions (also as Strings)
Any line of input data that comes from an S3 URI whose prefix matches one of the S3 URIs in the filter configuration that matches at least one of the regular expressions is included in the test input.
Any line of input data that comes from an S3 URI whose prefix matches one of the S3 URIs in the filter configuration that does not match any of the regular expressions is excluded from the test input.
Input data that does not come from an S3 URI whose prefix matches on of the S3 URIs in the filter configuration is not filtered.
If an input S3 URI matches multiple S3 URIs in the filter configuration, the most specific match is the one that is chosen for filtering purposes.

### Caching

Hasta caches the filtered input data locally to improve performance.
The first time a data source is referenced in a test, the filtered results are written locally.
Subsequent tests that access the same data source with the same filter are read from the local cache.
This results in a significant speedup on subsequent runs when dealing with aggressively filtered large data sets.
By default, the files are written to the `~/.hasta/cache` directory, but this can be controlled using the `cache_storage_root` configuration setting.

## Execution

Hasta sets up the environent variables specified by the `-cmdenv` switch in the job definition.
It also pulls down all cache files from S3 and stores them in local S3 storage.
For all cache files that do not have a `.rb` file extension, an environment variable is added to the `ENV` that points to the absolute path of the local file.

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

Hasta executes mappers and reducers in subprocesses.
This isolates each job and prevents the modifications to `ENV` and `$LOAD_PATH` described above from leaking into the parent process.

The output of the mapper is sorted before it is processed by the reducer.
The mapper output is sorted in ascending order, according to the natural sort order for Ruby Strings.

## Requirements

### Mappers and Reducers
1. must be stand-alone Ruby scripts
2. must be defined in the `Hasta.project_root`/`Hasta.project_steps` directory
3. must read their input lines from stdin and write their output lines to stdout
4. any data written to stderr will be logged at the error level using `Hasta.logger`


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2014 Swipely, Inc. See [LICENSE.txt](https://github.com/swipely/hasta/blob/master/LICENSE.txt) for further details.
