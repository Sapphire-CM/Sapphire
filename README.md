# Sapphire - Course Management System

This project is intended to be used to evaluate students during a course-term based on submissions with a variety of ratings.

[![Build Status](https://magnum.travis-ci.com/matthee/Sapphire.svg?token=pEdNnsdfG21w5iAAhDJf&branch=master)](https://magnum.travis-ci.com/matthee/Sapphire)

## Requirements

* Ruby 2.1.0 or higher
* Database
    - PostgreSQL or
    - sqlite3 (only basic support, no background jobs)
* Redis
* Sidekiq
* Node.js
    - on the server for assets precompilation
    - make sure it is part of PATH
    - v0.10.35 or above
* working SMTP server for email delivery

## Contributors
* Matthias Link
* Thomas Kriechbaumer

## MIT Open Source License

Copyright (C) 2012-2015 Matthias Link, Thomas Kriechbaumer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
