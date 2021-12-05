BEGIN { prevDepth = -1; depthIncreses = 0 }
{
	if (prevDepth != -1 && $1 > prevDepth) {
		depthIncreses++;
	}
	prevDepth = $1;
}
END { print "Number of depth increases:", depthIncreses }
