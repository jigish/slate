//
//  NSString+Levenshtein.m
//  Slate
//
//  Created by Jigish Patel on 3/1/12.
//  Copyright 2011 Jigish Patel. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see http://www.gnu.org/licenses

#import "NSString+Levenshtein.h"

@implementation NSString (Levenshtein)

- (float) levenshteinDistance:(NSString *)stringB {
  // normalize strings
  NSString * stringA = [NSString stringWithString: self];
  [stringA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [stringB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  stringA = [stringA lowercaseString];
  stringB = [stringB lowercaseString];

  // Step 1
  int k, i, j, cost, * d, distance;
  NSUInteger n = [stringA length];
  NSUInteger m = [stringB length];
  if( n++ != 0 && m++ != 0 ) {
    d = malloc( sizeof(int) * m * n );
    // Step 2
    for( k = 0; k < n; k++)
      d[k] = k;
    for( k = 0; k < m; k++)
      d[ k * n ] = k;
    // Step 3 and 4
    for( i = 1; i < n; i++ )
      for( j = 1; j < m; j++ ) {
        // Step 5
        if( [stringA characterAtIndex: i-1] ==
           [stringB characterAtIndex: j-1] )
          cost = 0;
        else
          cost = 1;
        // Step 6
        d[ j * n + i ] = [self smallestOf: d [ (j - 1) * n + i ] + 1
                                    andOf: d[ j * n + i - 1 ] +  1
                                    andOf: d[ (j - 1) * n + i -1 ] + cost ];
      }
    distance = d[ n * m - 1 ];
    free( d );
    return distance;
  }
  return 0.0;
}

- (float) sequentialDistance:(NSString *)stringB {
  NSString * stringA = [NSString stringWithString: self];
  [stringA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [stringB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  stringA = [stringA lowercaseString];
  stringB = [stringB lowercaseString];
  float distance = 0.0;
  for (NSInteger i = 0; i < MIN([stringA length], [stringB length]); i++) {
    if ([stringA characterAtIndex:i] == [stringB characterAtIndex:i]) distance++;
    else break;
  }
  return distance;
}


// return the minimum of a, b and c
- (int) smallestOf:(int)a andOf:(int)b andOf:(int)c {
  int min = a;
  if ( b < min )
    min = b;
  if( c < min )
    min = c;
  return min;
}

@end
