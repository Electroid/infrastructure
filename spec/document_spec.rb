require "document"
require "timecop"

describe Document do

    context "with incrementally updating document" do
        class IncrementalDoc
            include Document

            def initialize
                @revision = 0
                @cached = nil
            end

            def fetch!
                @cached = Time.now
                return @revision += 1
            end

            def cached
                @cached
            end
        end

        it "updates cache after document is called" do
            doc = IncrementalDoc.new
            expect(doc.cache).to eql 1
            expect(doc.document).to eql 2
            expect(doc.cache).to eql 2
        end

        it "does not update cache after fetch is called" do
            doc = IncrementalDoc.new
            expect(doc.cache).to eql 1
            expect(doc.fetch!).to eql 2
            expect(doc.cache).to eql 1
        end

        it "refreshes the cache" do
            doc = IncrementalDoc.new
            expect(doc.cached).to be_nil
            expect(doc.cache).to eql 1
            expect(doc.cached).to_not be_nil
            cached = doc.cached
            expect(doc.refresh!).to eql 2
            expect(doc.cached).to be > cached
        end

        it "expires the cache as time passes" do
            doc = IncrementalDoc.new
            expect(doc.cache).to eql 1
            Timecop.freeze(Time.now + 5.minutes) do
                expect(doc.cache).to eql 2
            end
        end
    end

    context "with nested data document" do
        class NestedDoc
            include Document

            def fetch!
                Array.new(5){rand(1...999999)}
            end
        end

        it "forwards missing method to document" do
            doc = NestedDoc.new
            expect(doc.size).to eql 5
            expect(doc.last).to be_an Integer
            expect(doc[0]).to be_an Integer
        end

        it "forwards missing method to cache" do
            doc = NestedDoc.new
            expect(doc.size_cache).to eql 5
            expect(doc.first_cache).to be_an Integer
            last = doc.last_cache
            expect(doc.last).not_to eql last
        end
    end

end
