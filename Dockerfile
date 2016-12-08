FROM ruby:2.3
RUN apt-get update -qq && apt-get install -y build-essential
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs

ENV APP_HOME /app  
RUN mkdir $APP_HOME  
WORKDIR $APP_HOME
ADD . $APP_HOME  

RUN bundle install
