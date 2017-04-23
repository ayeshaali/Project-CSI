/*
Program: Text Analysis Lab
Author: Ayesha Ali 
Date: 1/20/17 
*/

import rita.*;
float totalW = 0, totalC = 0, totalU = 0, totalWL = 0, totalV =0;
float totalS = 0, totalSR = 0, totalWS =0, totalCS =0;
float totalN = 0, totalVE = 0, totalAdj = 0, totalAdv =0;
int[] values0, values1, values2;
String[] keys0, keys1, keys2;
int wordc = 0, Wordc = 0, WordC = 0;

PrintWriter csv; 

void setup () {
  csv = createWriter("words.csv");
  csv.println("Book, Word Count, Unique Word Count, Average Word Length, Longest Word, Vocabulary Richness Ratio, Total Number of Sentences, Sentence Richness Ratio, Words per sentence, Characters Per Sentence, Parts of Speech (noun:verb:adj:adv)");

  analysis("oliverTwist.txt", "Oliver Twist");  
  analysis("greatExpectations.txt", "Great Expectations");
  analysis("aTaleOfTwoCities.txt", "A Tale of Two Cities");

  String totalP = (totalN/3)+" : "+(totalVE/3)+" : "+(totalAdj/3)+" : "+(totalAdv/3);
  csv.println("Average,"+(totalW/3)+","+(totalU/3)+","+(totalWL/3)+","+","+(totalV/3)*100+"% ,"+(totalS/3)+","+(totalSR/3)*100+"% ,"+(totalWS/3)+","+(totalCS/3)+","+totalP);
  csv.flush();
  csv.close();
}

void analysis(String txt, String name) {
  int charCWP = 0, charL=0, wordC = 0;
  int adj = 0, noun = 0, verb =0, adv = 0;
  String longestW = " ", parts = "";

  String lines[] = loadStrings(txt);
  String text = join(lines, " ");
  String sentence[] = RiTa.splitSentences(text);

  IntDict dictionary = new IntDict(), capitalized = new IntDict();
  RiLexicon lexicon = new RiLexicon();

  for (int lineN = 0; lineN< lines.length; lineN++) {
    charCWP += lines[lineN].length(); //character count w/ white space
    String words[] = splitTokens(lines[lineN]); //creating array w/ just words
    wordC += words.length; //number of words

    for (int wordN = 0; wordN< words.length; wordN++) {
      String letters = words[wordN]; //each word
      String letterR = "";
      
      for (int charN = 0; charN< letters.length(); charN++) {
        char z = letters.charAt(charN); //each letter
        if (z>64 && z<91 || z>96 && z<123) {
          charL++;
          letterR += z;
        } else if (z==45) {
          letterR+=" ";
        }
      }

      String longW[]= splitTokens(letterR);

      for (int i = 0; i<longW.length; i++) {
        //longest word
        if (longW[i].length() > longestW.length()) {
          longestW = longW[i];
        }
        
        //capitalized words
        if (longW[i].charAt(0)>64 && longW[i].charAt(0)<91) {
          if (capitalized.hasKey(longW[i])) {
            capitalized.increment(longW[i]);
          } else {
            capitalized.set(longW[i], 1);
          }
        }

        //unique words dictionary
        if (dictionary.hasKey(longW[i].toLowerCase())) {
          dictionary.increment(longW[i].toLowerCase());
        } else {
          dictionary.set(longW[i].toLowerCase(), 1);
        }

        //parts of speech
        {
          if (lexicon.isAdjective(longW[i])) {
            adj++;
          } else if (lexicon.isAdverb(longW[i])) {
            adv++;
          } else if (lexicon.isNoun(longW[i])) {
            noun++;
          } else if (lexicon.isVerb(longW[i])) {
            verb++;
          }
          parts = noun+" : "+verb+" : "+adj+" : "+adv;
        }
      }
    }
  }

  dictionary.sortValuesReverse();
  capitalized.sortValuesReverse();
  String[] keys = dictionary.keyArray();
  int[] values = dictionary.valueArray();

  String[] keys2 = capitalized.keyArray();
  int[] values2 = capitalized.valueArray();

  float vocabR = (dictionary.size()/float(wordC))*100;
  float sentenceR = (float(sentence.length)/values.length)*100;
  csv.println(name+","+wordC+","+keys.length+","+(float(charL)/wordC)+","+longestW+","+vocabR+"% ,"+(sentence.length)+","+sentenceR+"% ,"+(float(wordC)/sentence.length)+","+(float(charCWP)/sentence.length)+","+parts);

  {
    totalW += wordC;
    totalC += charCWP;
    totalU += keys.length;
    totalWL += (float(charL)/wordC);
    totalV += (dictionary.size()/float(wordC));
    totalS += (sentence.length);
    totalSR += (float(sentence.length)/values.length);
    totalWS += (float(wordC)/sentence.length);
    totalCS += (float(charCWP)/sentence.length);
    totalN +=noun;
    totalVE += verb;
    totalAdj += adj;
    totalAdv +=adv;
  }
  csv.println(","+"20 Most Frequent Words"+","+","+"20 Most Frequent Capitalized Words");
  for (int i =0; i<20; i++) {
    float UWpercent = (float(values[i])/wordC)*100;
    float UWpercent2 = (float(values2[i])/wordC)*100;
    csv.println(","+keys[i]+", "+nfs(UWpercent, 2, 2)+"%" +","+keys2[i]+", "+nfs(UWpercent2, 2, 2)+"%" );
  }

  csv.println(" ");
}