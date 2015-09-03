#!/usr/bin/env ruby

require "rubygems"
require "appscript"
include Appscript
require "active_support"
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

@mail = app("Mail")
@things = app("Things")
@nnw = app("NetNewsWire")
@evernote = app("Evernote")

def create_to_do(name,notes,source)
  unless @things.lists["Today"].to_dos[its.name.eq(name)].get.length > 0
    puts "Didn't find a thing named #{name}. Creating a task."
    task = @things.make(:at => app.lists["Today"].beginning, :new => :to_do, :with_properties => {
                          :name => name,
                          :tag_names => "panopticon,#{source}",
                          :notes => notes,
                          :due_date => Time.now + 8.hours
                        })
  else
    puts "I found a thing with the name '#{name}', not creating a task."
  end
end

# handle mail stuff
accounts = {"Personal" => "INBOX",
  "Both Pieces IMAP" => "INBOX",
  "Exchange" => "INBOX"}

accounts.each do |acct,box|
  account = @mail.accounts[acct].get

  inbox = account.mailboxes[box].get

  messages = inbox.messages[its.flagged_status.eq(true).and(
                                                            its.date_received.gt(Time.now - 2.days)
                                                            )].get

  messages.each do |m|
    create_to_do("#{m.subject.get} - #{m.sender.get} (#{acct})","", "mail")
  end
end

# handle NetNewsWire flagged items

subs = @nnw.subscriptions[its.display_name.eq('Flagged Items')].first.get

subs.headlines.get.each do |h|
  if h.date_arrived.get > Date.today - 2.days
    create_to_do(h.title.get,"","RSS")
  end
end

# handle Instapaper subscriptions
content = ""
instapaper_feed = "http://www.instapaper.com/rss/..."

open(instapaper_feed) do |s|
  content = s.read
end

rss = RSS::Parser.parse(content, false)

rss.items.each do |i|
  if i.pubDate > (Time.now - 2.days)
    create_to_do(i.title,"","Instapaper")
  end
end

# handle Evernote stuff

notes = @evernote.notebooks["Inbox"].notes[its.creation_date.gt(Time.now - 2.days)].get

notes.each do |n|
  create_to_do(n.title.get, "", "Evernote")
end
