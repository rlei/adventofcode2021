(println
  (->> (line-seq (java.io.BufferedReader. *in*))
       (map #(Integer/parseInt %))
       (partition 3 1) 
       (map #(reduce + %))
       (reduce (fn [state currentDepth]
                 (let [prevDepth (first state) depthIncreases (second state)] 
                   [currentDepth
                    (if (> currentDepth prevDepth) (inc depthIncreases) depthIncreases)]))
               [Integer/MAX_VALUE 0]) 
       (second)))
