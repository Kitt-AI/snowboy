all: Demo.class

Demo.class: Demo.java
	javac -classpath java Demo.java

run: Demo.class
	java -classpath .:java -Djava.library.path=jniLibs Demo

clean:
	-rm -f Demo.class
