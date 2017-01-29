FROM ruby:2.2.4
MAINTAINER Joseph D. Marhee <joseph@marhee.me>

ADD app.rb app.rb
ADD Gemfile Gemfile

RUN bundle install

ENTRYPOINT ["ruby","app.rb","-o","0.0.0.0"]
